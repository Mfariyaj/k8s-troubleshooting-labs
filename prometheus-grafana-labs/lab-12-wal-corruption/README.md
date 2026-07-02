## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Prometheus/Grafana via docker-compose)
2. Open Prometheus: http://localhost:9090 → Status → Targets
3. Open Grafana: http://localhost:3000 (admin/admin)
4. Observe what's broken (targets DOWN, alerts not firing, dashboards empty)
5. Fix the configuration files and restart
6. Check `solution.md` if stuck

---

# Lab 12: WAL Corruption — Prometheus Won't Start After Crash

## ⭐⭐⭐⭐⭐ Expert Level

### Scenario

Your production Prometheus instance was running on a node that experienced a kernel panic. The container was killed with SIGKILL (no graceful shutdown). After the node recovered, Prometheus refuses to start. It shows WAL replay errors and exits immediately.

The monitoring team is blind — no metrics are being collected. Alerts aren't firing. You need to recover Prometheus ASAP, understanding that some recent data will be lost. Management needs to know exactly how much data is unrecoverable.

### Environment
- Prometheus v2.51.0 with WAL compression enabled
- Docker Compose deployment
- Node exporter as the scrape target
- 30-day retention configured

### Symptoms

```
# Prometheus exits immediately after start
$ docker compose up -d prometheus
$ docker logs prometheus-wal-corrupt

level=info ts=2024-03-15T10:00:01.000Z caller=main.go:549 msg="Starting Prometheus"
level=info ts=2024-03-15T10:00:01.100Z caller=main.go:987 msg="Starting TSDB..."
level=info ts=2024-03-15T10:00:01.200Z caller=db.go:1234 msg="Replaying WAL, this may take a while"
level=error ts=2024-03-15T10:00:01.500Z caller=db.go:1456 msg="WAL segment replay failed" 
  segment=00000001 err="unexpected CRC32 checksum: got 0x4a2b3c1d, want 0x8f7e6d5c"
level=error ts=2024-03-15T10:00:01.600Z caller=wal.go:789 
  msg="error reading WAL segment" segment="/prometheus/wal/00000003" 
  err="record at offset 524288: invalid record type 0"
level=error ts=2024-03-15T10:00:01.700Z caller=db.go:1500 
  msg="WAL replay failed" 
  err="opening WAL: segment 00000001: unexpected CRC32 checksum"
level=error ts=2024-03-15T10:00:01.800Z caller=main.go:1000 
  msg="Error opening storage" 
  err="WAL segment /prometheus/wal/00000001: corrupt record at byte offset 262144"
level=info ts=2024-03-15T10:00:01.900Z caller=main.go:1001 msg="Prometheus exiting with error"

# Container exits with code 2
$ docker ps -a | grep prometheus
CONTAINER ID   IMAGE                    STATUS                   NAMES
b7c3d891...    prom/prometheus:v2.51.0  Exited (2) 5 secs ago   prometheus-wal-corrupt

# WAL directory state
$ docker run --rm -v lab-12-wal-corruption_prometheus-data:/data alpine ls -la /data/wal/
total 4196
drwxr-xr-x    2 nobody   nobody        4096 Mar 15 10:00 .
drwxr-xr-x    4 nobody   nobody        4096 Mar 15 09:00 ..
-rw-r--r--    1 nobody   nobody     1048576 Mar 15 09:45 00000001
-rw-r--r--    1 nobody   nobody     1048576 Mar 15 09:50 00000002
-rw-r--r--    1 nobody   nobody      524800 Mar 15 09:55 00000003

# No checkpoints exist (they should!)
$ docker run --rm -v lab-12-wal-corruption_prometheus-data:/data alpine ls /data/wal/checkpoint*
ls: /data/wal/checkpoint*: No such file or directory

# Docker compose shows the kill signal issue
$ grep -A2 stop_signal docker-compose.yml
    stop_signal: SIGKILL
    stop_grace_period: 0s
```

### Your Task

1. Understand why the WAL is corrupted (SIGKILL + no checkpoint + compression)
2. Assess what data is recoverable vs. permanently lost
3. Get Prometheus running again (multiple recovery strategies exist)
4. Fix the deployment to prevent future corruption
5. Implement proper graceful shutdown handling

### Useful Commands

```bash
# Check WAL segment sizes and timestamps
docker run --rm -v lab-12-wal-corruption_prometheus-data:/prometheus alpine ls -la /prometheus/wal/

# Try to start Prometheus and observe errors
docker compose up prometheus
docker logs prometheus-wal-corrupt --tail 50

# Inspect WAL segment headers
docker run --rm -v lab-12-wal-corruption_prometheus-data:/prometheus alpine hexdump -C /prometheus/wal/00000001 | head -20

# Check for existing TSDB blocks (persisted data that's safe)
docker run --rm -v lab-12-wal-corruption_prometheus-data:/prometheus alpine ls -la /prometheus/
docker run --rm -v lab-12-wal-corruption_prometheus-data:/prometheus alpine find /prometheus -name "meta.json" -exec cat {} \;

# Use promtool to check WAL (if available)
docker run --rm -v lab-12-wal-corruption_prometheus-data:/prometheus prom/prometheus:v2.51.0 promtool tsdb analyze /prometheus

# Attempt WAL repair
docker run --rm -v lab-12-wal-corruption_prometheus-data:/prometheus prom/prometheus:v2.51.0 promtool tsdb clean-tombstones /prometheus

# Check TSDB block integrity
docker run --rm -v lab-12-wal-corruption_prometheus-data:/prometheus prom/prometheus:v2.51.0 promtool tsdb verify /prometheus

# Nuclear option: remove corrupt WAL (loses in-flight data)
docker run --rm -v lab-12-wal-corruption_prometheus-data:/prometheus alpine rm -rf /prometheus/wal

# Check Docker stop behavior
docker inspect prometheus-wal-corrupt --format '{{.Config.StopSignal}}'
docker inspect prometheus-wal-corrupt --format '{{.HostConfig.RestartPolicy}}'

# Monitor during recovery
docker stats prometheus-wal-corrupt --no-stream
```

### Hints

<details>
<summary>Hint 1</summary>
The `docker-compose.yml` has `stop_signal: SIGKILL` and `stop_grace_period: 0s`. This means Prometheus never gets a chance to flush its WAL and create a checkpoint before shutdown. The fix involves changing to `SIGTERM` with at least a 30-second grace period. But first you need to recover the current corruption.
</details>

<details>
<summary>Hint 2</summary>
Prometheus stores data in two places: (1) WAL directory (recent, unflushed data) and (2) TSDB blocks (persisted, compacted data). The corruption only affects the WAL. You can safely delete the WAL directory to recover — you'll lose the last 2 hours of data (the default head block duration), but all persisted blocks remain intact.
</details>

<details>
<summary>Hint 3</summary>
For a proper fix: (1) Remove the corrupt WAL: `rm -rf /prometheus/wal`, (2) Change `stop_signal` to `SIGTERM` and `stop_grace_period` to `30s`, (3) Consider adding `--storage.tsdb.min-block-duration=30m` to flush more frequently, (4) Optionally disable `--storage.tsdb.wal-compression` if crash resilience is more important than disk space, (5) Add a startup probe so orchestrators don't kill Prometheus during long WAL replays.
</details>

---

**Category:** Prometheus / Storage & Recovery  
**Difficulty:** ⭐⭐⭐⭐⭐ Expert  
**Time Estimate:** 15-25 minutes  
**Skills Tested:** TSDB internals, WAL mechanics, crash recovery, Docker signal handling, data loss assessment
