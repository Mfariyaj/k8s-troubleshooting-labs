# Lab 15: Container Runtime Shim Death — Ghost Containers

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Multiple containers in production show as "Up" in `docker ps` but are completely unresponsive. `docker exec` hangs indefinitely, `docker logs --follow` produces nothing, and the application inside is dead. The containers have been in this "ghost" state for hours.

Root cause: The containerd shim process (`containerd-shim-runc-v2`) that manages each container's I/O and signals was OOM-killed by the kernel. The Docker daemon still thinks the container is running because it lost the connection to the shim but didn't receive a proper exit notification.

This happens because:
1. Container memory limits are too tight
2. When the container OOMs, the kernel's OOM killer sometimes targets the shim instead
3. The shim's OOM score adjustment (`oom_score_adj`) isn't protective enough
4. containerd doesn't detect shim death and restart it
5. Docker daemon's connection to containerd shows stale container state

## Symptoms Observed

```
$ docker ps
CONTAINER ID   IMAGE         STATUS          NAMES
a1b2c3d4e5f6   memory-hog    Up 3 hours      memory-hog
b2c3d4e5f6a7   worker-img    Up 3 hours      worker-a

$ docker exec memory-hog echo "alive"
^C (hangs indefinitely, never returns)

$ docker logs --follow memory-hog
(produces nothing, hangs)

$ docker inspect memory-hog --format '{{.State.Status}}'
running

$ docker inspect memory-hog --format '{{.State.OOMKilled}}'
false

$ docker top memory-hog
Error response from daemon: container a1b2c3d4e5f6 is not running

$ docker stats --no-stream memory-hog
CONTAINER ID   NAME         CPU %   MEM USAGE / LIMIT   NET I/O   BLOCK I/O
a1b2c3d4..     memory-hog   0.00%   0B / 128MiB         0B / 0B   0B / 0B

$ ps aux | grep containerd-shim | grep memory-hog
(no output — shim is GONE)

$ ps aux | grep containerd-shim
root     1234  0.0  0.1  714568  8480 ?  Sl   10:00   0:05 containerd-shim-runc-v2 -namespace moby -id <other-container-id>
(only shims for OTHER containers visible — memory-hog's shim is missing)

$ dmesg | grep -i oom
[86400.123456] Out of memory: Killed process 5678 (containerd-shim) total-vm:714568kB, anon-rss:131072kB
[86400.123457] oom_kill_process+0x1a8/0x2b0
[86400.123458] Memory cgroup out of memory. Kill process 5678 (containerd-shim-r) score 500 or sacrifice child

$ journalctl -u containerd --since "3 hours ago" | tail
Jul 01 10:14:22 prod-host containerd[890]: level=warning msg="shim disconnected" id="a1b2c3d4e5f6..."
Jul 01 10:14:22 prod-host containerd[890]: level=error msg="failed to receive exit event" error="transport is closing"

$ cat /proc/$(pgrep -f "containerd-shim.*memory-hog")/oom_score_adj
cat: /proc//oom_score_adj: No such file or directory

$ docker events --since="3h" --filter container=memory-hog
(no events recorded after shim death)
```

## What's Broken

1. **Container memory limit too tight (128M)** — app tries to allocate 200MB, triggering OOM
2. **OOM killer targets shim** — shim's `oom_score_adj` isn't low enough to protect it
3. **containerd doesn't restart dead shims** — shim death leaves container in limbo
4. **Docker daemon shows stale state** — no notification mechanism for shim death without proper exit
5. **No liveness probe at runtime level** — no mechanism to detect and restart ghost containers

## Debugging Commands

```bash
# Check if container is truly running
docker top memory-hog
docker stats --no-stream memory-hog

# Check container's cgroup memory state
cat /sys/fs/cgroup/docker/$(docker inspect -f '{{.Id}}' memory-hog)/memory.current 2>/dev/null
cat /sys/fs/cgroup/memory/docker/$(docker inspect -f '{{.Id}}' memory-hog)/memory.usage_in_bytes 2>/dev/null

# Verify shim process existence
ps aux | grep "containerd-shim" | grep $(docker inspect -f '{{.Id}}' memory-hog | head -c 12)
ls /proc/$(pgrep -f "containerd-shim.*$(docker inspect -f '{{.Id}}' memory-hog | head -c 12)") 2>/dev/null

# Check OOM kill events
dmesg | grep -i "oom\|killed process\|out of memory"
journalctl -k | grep -i "oom\|killed process"

# Check containerd logs for shim disconnect
journalctl -u containerd --since "1 hour ago" | grep -i "shim\|disconnect\|error"
journalctl -u docker --since "1 hour ago" | grep -i "shim\|OOM\|kill"

# Check oom_score_adj for running shims
for pid in $(pgrep containerd-shim); do echo "$pid: $(cat /proc/$pid/oom_score_adj)"; done

# Check container's OOM score
docker inspect --format '{{.HostConfig.OomScoreAdj}}' memory-hog

# Try to signal the container (will fail with dead shim)
docker kill --signal=0 memory-hog

# Force remove ghost container
docker rm -f memory-hog

# Check containerd state directly
ctr -n moby containers ls
ctr -n moby tasks ls

# Inspect containerd shim configuration
cat /etc/containerd/config.toml | grep -A5 oom_score
```

## Hints

<details>
<summary>Hint 1</summary>
The root issue is memory limits being lower than what the application actually needs. Set realistic memory limits based on actual usage. Use `docker stats` to observe real consumption before setting limits. The shim getting OOM-killed is a side effect of the kernel's memory pressure.
</details>

<details>
<summary>Hint 2</summary>
Protect the containerd shim from OOM by setting `oom_score_adj` to -999 in containerd config (`/etc/containerd/config.toml` → `[plugins."io.containerd.runtime.v1.linux"]` → `shim_oom_score = -999`). This tells the kernel to prefer killing the container process over the shim.
</details>

<details>
<summary>Hint 3</summary>
For ghost containers, the recovery is: `docker rm -f <container>` to force-remove the stale state, then fix the underlying memory issue. For prevention, implement a watchdog that compares `docker ps` output against actual shim processes: if a container shows "Up" but its shim PID is gone, force-restart it.
</details>

## Learning Objectives

- Understanding containerd shim architecture and lifecycle
- Diagnosing OOM kills in container runtime infrastructure
- Configuring OOM score adjustments for critical daemon processes
- Recovering from ghost container states
- Implementing runtime health monitoring beyond application health checks
- Linux OOM killer behavior and cgroup memory controller
