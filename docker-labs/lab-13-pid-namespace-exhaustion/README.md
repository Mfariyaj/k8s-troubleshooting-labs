# Lab 13: PID Namespace Exhaustion — Zombie Process Accumulation

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your container orchestration platform reports that containers can't fork new processes. The host kernel returns `EAGAIN` (Resource temporarily unavailable) on `fork()` calls. Investigation reveals thousands of zombie processes (`Z` state) consuming PID slots.

The root causes are layered:
- Containers share the host PID namespace (`pid: host`)
- Worker processes fork children aggressively without reaping them
- SIGCHLD is explicitly ignored (`trap '' SIGCHLD`), preventing zombie cleanup
- No proper init system (tini/dumb-init) runs as PID 1
- No `pids_limit` configured to prevent runaway containers
- Grandchild processes become orphans when parents exit, reparented to PID 1 which doesn't reap them

## Symptoms Observed

```
$ docker exec -it worker-alpha bash
OCI runtime exec failed: exec failed: unable to start container process:
unable to init seccomp listener: can't allocate memory: unknown

$ docker logs worker-alpha | tail -5
[WORKER-alpha] Status: children_spawned=4200 zombies=3847 total_pids=32591
[WORKER-alpha] ERROR: Reached max children (1000), still spawning...

$ ps aux | grep -c Z
4291

$ cat /proc/sys/kernel/pid_max
32768

$ ps aux | head -20
USER       PID %CPU %MEM    VSZ   RSS TTY  STAT START   TIME COMMAND
root         1  0.0  0.0  168092 11412 ?   Ss   Jun28   0:11 /sbin/init
...
root     28493  0.0  0.0      0     0 ?    Z    10:42   0:00 [worker.sh] <defunct>
root     28494  0.0  0.0      0     0 ?    Z    10:42   0:00 [worker.sh] <defunct>
root     28495  0.0  0.0      0     0 ?    Z    10:42   0:00 [sleep] <defunct>
root     28496  0.0  0.0      0     0 ?    Z    10:42   0:00 [sleep] <defunct>
...

$ docker inspect worker-alpha --format '{{.HostConfig.PidMode}}'
host

$ docker inspect worker-alpha --format '{{.HostConfig.PidsLimit}}'
0

$ docker inspect worker-alpha --format '{{.HostConfig.Init}}'
<nil>

$ dmesg | tail -10
[462918.423] cgroup: fork rejected by pids controller in /system.slice/docker.service
[462918.424] docker0: port 1(veth4a5b6c) entered blocking state
[462919.112] Out of memory: Killed process 28501 (worker.sh) total-vm:4096kB

$ journalctl -u docker.service | tail -5
Jul 01 03:14:22 prod-host dockerd[1234]: msg="Container failed to start" error="cannot allocate memory"
Jul 01 03:14:22 prod-host dockerd[1234]: msg="handler for POST /v1.43/exec/.../start returned error: cannot allocate memory"
```

## What's Broken

1. **`pid: "host"`** — containers share host PID namespace, exhausting host PID limit
2. **No `pids_limit`** — no cgroup restriction on per-container PID count
3. **`trap '' SIGCHLD`** — explicitly ignores child termination signals
4. **No init process** — bash as PID 1 doesn't reap zombies; `init: true` not set
5. **Unbounded forking** — worker forks without waiting for children to complete
6. **Grandchild orphaning** — children exit while their sub-children are still running

## Debugging Commands

```bash
# Count zombie processes on host
ps aux | awk '{print $8}' | grep -c Z

# Show all zombie processes
ps aux | awk '$8=="Z" {print $0}'

# Check host PID limit
cat /proc/sys/kernel/pid_max
cat /proc/sys/kernel/threads-max

# Count total processes
ls /proc | grep -c "^[0-9]"

# Check container PID mode
docker inspect --format '{{.HostConfig.PidMode}}' worker-alpha

# Check container PID limit
docker inspect --format '{{.HostConfig.PidsLimit}}' worker-alpha

# Check if init is configured
docker inspect --format '{{.HostConfig.Init}}' worker-alpha

# Monitor PID usage in real-time
watch -n1 'ps aux | grep -c Z; echo "---"; cat /proc/loadavg'

# Check cgroup pids controller
cat /sys/fs/cgroup/pids/docker/$(docker inspect -f '{{.Id}}' worker-alpha)/pids.current
cat /sys/fs/cgroup/pids/docker/$(docker inspect -f '{{.Id}}' worker-alpha)/pids.max

# Inspect kernel OOM and fork failures
dmesg | grep -i "fork\|oom\|pids\|cgroup"
journalctl -u docker.service --since "1 hour ago"

# strace to see failed fork calls
strace -f -e trace=clone,fork,vfork docker exec worker-alpha ls

# Check what init system the container uses
docker exec worker-alpha cat /proc/1/comm
docker exec worker-alpha cat /proc/1/cmdline | tr '\0' ' '
```

## Hints

<details>
<summary>Hint 1</summary>
Remove `pid: "host"` from docker-compose.yml. Each container should have its own PID namespace. Add `pids_limit: 200` to prevent any single container from exhausting PIDs.
</details>

<details>
<summary>Hint 2</summary>
Add `init: true` to each service in docker-compose.yml. This injects `tini` as PID 1, which properly reaps zombie processes. Alternatively, use `ENTRYPOINT ["tini", "--", "/app/worker.sh"]` in the Dockerfile.
</details>

<details>
<summary>Hint 3</summary>
Fix the worker.sh script: Replace `trap '' SIGCHLD` with `trap 'wait' SIGCHLD` to reap children. Add `wait -n` in the loop to block when too many children are running. This prevents zombie accumulation at the application level.
</details>

## Learning Objectives

- Understanding PID namespaces and their isolation properties
- Diagnosing zombie process accumulation in containers
- Implementing proper PID 1 init systems (tini, dumb-init)
- Configuring cgroup pids controller limits
- Unix signal handling (SIGCHLD) and process reaping
- Debugging fork failures at kernel level
