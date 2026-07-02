## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (builds and runs broken containers)
2. Check: `docker ps`, `docker logs <container>`
3. Test: Try `curl`, `docker exec`, check connectivity
4. Observe the failure and identify root cause
5. Fix the Dockerfile/docker-compose.yml and rebuild
6. Check `solution.md` if stuck

---

# Lab 08 - Container OOM Killed

## Difficulty: ⭐⭐⭐

## Scenario
A Java Spring Boot application keeps getting killed by the Docker runtime. The container starts, runs for a few seconds, then gets OOM (Out of Memory) killed. The JVM heap is configured to use 512MB but the container memory limit is only 256MB.

## What You'll See
When you run `./deploy.sh`:

```
$ docker compose ps
NAME           STATUS                     PORTS
lab08-java     Exited (137) 5 seconds ago

$ docker inspect lab08-java --format='{{.State.OOMKilled}}'
true

$ docker compose logs app
app_1  | Starting Java application with -Xmx512m...
app_1  | OpenJDK 64-Bit Server VM warning: INFO: os::commit_memory(0x..., 536870912, 0) failed; error='Not enough space'
app_1  | Killed
```

Exit code 137 = SIGKILL (OOM killer).

## Hints
1. What's the container memory limit in docker-compose.yml?
2. What JVM heap size is configured (-Xmx)?
3. Remember: JVM uses MORE memory than just heap (metaspace, thread stacks, etc.)
4. The total JVM memory ≈ heap + metaspace + threads + native = typically 1.5-2x heap

## Troubleshooting Commands
```bash
# Check container exit code
docker inspect lab08-java --format='{{.State.ExitCode}}'

# Check if OOM killed
docker inspect lab08-java --format='{{.State.OOMKilled}}'

# Check memory limits
docker inspect lab08-java --format='{{.HostConfig.Memory}}'

# Check container events
docker events --filter 'container=lab08-java' --since 5m

# Check docker stats (if container is running)
docker stats --no-stream lab08-java
```

## Resolution
The JVM's `-Xmx512m` setting requests 512MB of heap alone. Add metaspace (~100MB), thread stacks, and native memory, and the JVM needs ~700-800MB. But the container limit is only 256MB.

**Fix options:**
1. Increase container memory limit to accommodate JVM: `mem_limit: 768m`
2. Reduce JVM heap to fit: `-Xmx128m -Xms64m`
3. Use container-aware JVM flags: `-XX:MaxRAMPercentage=75.0` (lets JVM auto-detect container limits)
4. Best practice: Set `mem_limit: 512m` and use `-XX:MaxRAMPercentage=75.0`
