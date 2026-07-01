# Lab 11: overlay2 Disk Exhaustion — Production Host Running Out of Space

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your production Docker host is critically low on disk space. The monitoring alert fired at 3 AM showing `/var/lib/docker` consuming 95% of the partition. Multiple services are failing because containers can't write logs or create new layers. The host has been running for 6 months without any disk cleanup automation.

Investigation reveals a perfect storm of disk waste:
- Container logs growing unbounded (json-file driver, no rotation)
- Dangling images from months of CI/CD builds never pruned
- Build cache from BuildKit accumulating without limits
- Exited containers never removed, still holding layer references
- Orphaned volumes from deleted containers

## Symptoms Observed

```
$ df -h /var/lib/docker
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       100G   97G  3.0G  97% /var/lib/docker

$ docker run hello-world
Error response from daemon: failed to create shim task: OCI runtime create failed:
unable to retrieve OCI runtime error: write /var/lib/docker/overlay2/.../merged:
no space left on device: unknown

$ docker logs payment-service | wc -l
28493847

$ docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          147       12        45.23GB   38.91GB (86%)
Containers      89        8         31.67GB   31.67GB (100%)
Local Volumes   34        6         12.45GB   9.82GB (78%)
Build Cache     203       0         8.94GB    8.94GB

$ du -sh /var/lib/docker/containers/*/
4.2G    /var/lib/docker/containers/a1b2c3d4.../
6.8G    /var/lib/docker/containers/e5f6g7h8.../
3.1G    /var/lib/docker/containers/i9j0k1l2.../

$ ls /var/lib/docker/containers/a1b2c3d4*/*-json.log | xargs ls -lh
-rw-r----- 1 root root 4.2G Jun 30 03:14 a1b2c3d4...-json.log

$ docker inspect payment-service --format '{{.HostConfig.LogConfig}}'
{json-file map[]}

$ cat /etc/docker/daemon.json
{
  "storage-driver": "overlay2"
}
```

## What's Broken

The `daemon.json` has no log rotation configured. The application generates thousands of log lines per second. Combined with no container/image/volume pruning, the disk fills up completely.

## Debugging Commands

```bash
# Check disk usage breakdown
docker system df -v
du -sh /var/lib/docker/*
du -sh /var/lib/docker/overlay2/
du -sh /var/lib/docker/containers/*

# Find largest log files
find /var/lib/docker/containers -name "*-json.log" -exec ls -lh {} \;

# Check container log configuration
docker inspect --format '{{.HostConfig.LogConfig}}' $(docker ps -q)

# List dangling images
docker images -f dangling=true
docker images -f dangling=true -q | wc -l

# Check build cache
docker builder prune --dry-run

# List exited containers still consuming space
docker ps -a -f status=exited --format "{{.ID}} {{.Names}} {{.Size}}"

# Find orphaned volumes
docker volume ls -f dangling=true

# Check overlay2 layer usage
ls /var/lib/docker/overlay2/ | wc -l

# Inspect daemon.json for log rotation
cat /etc/docker/daemon.json

# Check what's using inodes
df -i /var/lib/docker

# Analyze container sizes
docker ps -a --size --format "table {{.ID}}\t{{.Names}}\t{{.Size}}\t{{.Status}}"
```

## Hints

<details>
<summary>Hint 1</summary>
The daemon.json needs `log-opts` with `max-size` and `max-file` to enable log rotation. Without these, json-file logs grow forever.
</details>

<details>
<summary>Hint 2</summary>
`docker system prune -a --volumes` removes dangling images, stopped containers, unused networks, and orphaned volumes — but requires daemon restart for log rotation to take effect on existing containers.
</details>

<details>
<summary>Hint 3</summary>
For existing containers already consuming massive log space, you can truncate the log file directly: `truncate -s 0 /var/lib/docker/containers/<id>/<id>-json.log`. But the permanent fix requires recreating containers with proper log-opts.
</details>

## Learning Objectives

- Understanding Docker storage driver internals (overlay2)
- Configuring production-grade log rotation in daemon.json
- Implementing automated disk cleanup policies
- Diagnosing multi-source disk exhaustion
- Managing Docker build cache lifecycle
