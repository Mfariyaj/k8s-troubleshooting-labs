# Lab 11: High Cardinality Explosion — Prometheus OOM Kill

## ⭐⭐⭐⭐⭐ Expert Level

### Scenario

Your production Prometheus instance keeps getting OOM-killed every 30-60 minutes. The on-call team restarted it multiple times, but it crashes again after loading metrics. The SRE team suspects a recently deployed microservice is generating excessive time series, but they can't identify which metric or label is the culprit before Prometheus dies again.

The TSDB head chunks are consuming all available RAM, and the container orchestrator kills it. After restart, it replays the WAL and immediately OOMs again — creating a death loop.

### Environment
- Prometheus v2.51.0 with 512MB memory limit
- A Python metrics server exposing application metrics
- Docker Compose orchestration

### Symptoms

```
# Prometheus container keeps restarting
$ docker ps -a
CONTAINER ID   IMAGE                    STATUS                        NAMES
a3f2c891...    prom/prometheus:v2.51.0  Exited (137) 2 minutes ago   prometheus-cardinality
...

# Docker events show OOM kill
$ docker events --filter container=prometheus-cardinality --since 10m
2024-03-15T14:23:01.234567 container oom prometheus-cardinality

# Prometheus logs before crash
level=warn ts=2024-03-15T14:22:55.123Z caller=scrape.go:1234 component="scrape manager" 
  msg="appended samples" series_added=487293 
  series_total=2847291 scrape_samples_scraped=487293
level=info ts=2024-03-15T14:22:58.456Z caller=head.go:842 
  msg="Head GC completed" duration=12.345s
level=warn ts=2024-03-15T14:23:00.789Z caller=head.go:123 
  msg="TSDB head series count very high" count=3421567
runtime: out of memory: cannot allocate 134217728-byte block (939524096 in use)
goroutine 1 [running]:
runtime.throw(...)

# After restart — OOMs during WAL replay
level=info ts=2024-03-15T14:25:01.000Z caller=main.go:1234 
  msg="Starting WAL replay"
level=info ts=2024-03-15T14:25:45.000Z caller=head.go:456 
  msg="WAL replay progress" replayed=2500000 total=3421567
runtime: out of memory: cannot allocate...

# TSDB stats API (if you can catch it alive)
$ curl -s localhost:9090/api/v1/status/tsdb | jq '.data.headStats'
{
  "numSeries": 3421567,
  "numLabelPairs": 8943221,
  "chunkCount": 6843134,
  "minTime": 1710505200000,
  "maxTime": 1710508800000
}

# Top series by cardinality
$ curl -s localhost:9090/api/v1/status/tsdb | jq '.data.seriesCountByMetricName[:5]'
[
  {"name": "http_request_duration_seconds", "value": 2847291},
  {"name": "user_request_total", "value": 412893},
  {"name": "active_session_info", "value": 161383},
  {"name": "prometheus_tsdb_head_series", "value": 1},
  {"name": "up", "value": 2}
]
```

### Your Task

1. Identify which metrics and labels are causing the cardinality explosion
2. Understand why Prometheus can't recover (WAL replay OOM loop)
3. Fix the immediate crisis (get Prometheus running again)
4. Implement guardrails to prevent future cardinality explosions
5. Fix the application to not expose unbounded labels

### Useful Commands

```bash
# Check container memory usage
docker stats prometheus-cardinality --no-stream

# View Prometheus logs
docker logs prometheus-cardinality --tail 100

# Check TSDB status (if Prometheus is alive)
curl -s localhost:9090/api/v1/status/tsdb | jq .

# Check top cardinality metrics
curl -s localhost:9090/api/v1/status/tsdb | jq '.data.seriesCountByMetricName[:10]'

# Check label value cardinality
curl -s localhost:9090/api/v1/status/tsdb | jq '.data.labelValueCountByLabelName[:10]'

# Check head series count
curl -s localhost:9090/api/v1/query?query=prometheus_tsdb_head_series

# Check scrape samples
curl -s localhost:9090/api/v1/query?query=scrape_samples_scraped

# Check memory usage via metrics
curl -s localhost:9090/api/v1/query?query=process_resident_memory_bytes

# Force Prometheus reload
curl -X POST localhost:9090/-/reload

# Check application metrics directly
curl -s localhost:8000/metrics | head -50
curl -s localhost:8000/metrics | wc -l

# Count unique label values
curl -s localhost:8000/metrics | grep -oP 'request_id="[^"]*"' | sort -u | wc -l
curl -s localhost:8000/metrics | grep -oP 'user_id="[^"]*"' | sort -u | wc -l

# Check WAL size
docker exec prometheus-cardinality du -sh /prometheus/wal/
```

### Hints

<details>
<summary>Hint 1</summary>
The application exposes `request_id`, `user_id`, and `session_id` as metric labels. Each unique combination creates a new time series. With UUIDs as request IDs, you get a new series for EVERY request. Check `curl localhost:8000/metrics | wc -l` and watch it grow.
</details>

<details>
<summary>Hint 2</summary>
To break the OOM-restart loop, you need to either: (a) delete the WAL directory so Prometheus starts fresh without replaying millions of series, or (b) use `--storage.tsdb.wal-replay-memory-limit` flag, or (c) temporarily increase the memory limit. Then immediately add `sample_limit` to the scrape config.
</details>

<details>
<summary>Hint 3</summary>
The proper fix involves multiple layers: (1) Add `metric_relabel_configs` with `action: labeldrop` for `request_id|user_id|session_id`, (2) Set `sample_limit: 10000` per scrape job, (3) Fix the application to not expose unbounded labels — use histograms with bounded buckets instead, (4) Consider `--storage.tsdb.out-of-order-time-window` for recovery.
</details>

---

**Category:** Prometheus / Observability  
**Difficulty:** ⭐⭐⭐⭐⭐ Expert  
**Time Estimate:** 20-30 minutes  
**Skills Tested:** TSDB internals, cardinality management, metric_relabel_configs, WAL recovery, application instrumentation best practices
