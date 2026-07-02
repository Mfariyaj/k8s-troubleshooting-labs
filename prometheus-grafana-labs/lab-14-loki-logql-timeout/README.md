## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Prometheus/Grafana via docker-compose)
2. Open Prometheus: http://localhost:9090 → Status → Targets
3. Open Grafana: http://localhost:3000 (admin/admin)
4. Observe what's broken (targets DOWN, alerts not firing, dashboards empty)
5. Fix the configuration files and restart
6. Check `solution.md` if stuck

---

# Lab 14: Loki LogQL Query Timeouts — Can't Search Logs

## ⭐⭐⭐⭐⭐ Expert Level

### Scenario

Your team recently deployed Grafana Loki as a centralized log aggregation solution. The ingestion pipeline appears to be working (Promtail shows as connected), but every LogQL query in Grafana times out or returns empty results. Engineers are complaining they can't search logs at all.

The Platform team tuned Loki's configuration for "resource efficiency" but went too aggressive — now the system is effectively unusable for queries. Additionally, Promtail is failing to push logs silently, and the chunk sizes are so large that even simple queries require loading massive amounts of data.

Developers are using `kubectl logs` as a workaround, but this doesn't scale. Fix the logging platform.

### Environment
- Grafana Loki v2.9.5 (monolithic mode)
- Promtail v2.9.5 (log shipper)
- Grafana v10.4.0 (visualization)
- Log generators producing JSON-formatted logs
- Docker Compose orchestration

### Symptoms

```
# Grafana Explore panel shows timeout errors
# Query: {job="containerlogs"}
Error: context deadline exceeded

# Direct Loki API query — timeout
$ curl -s "http://localhost:3100/loki/api/v1/query_range" \
    --data-urlencode 'query={job="containerlogs"}' \
    --data-urlencode 'start=1710460800000000000' \
    --data-urlencode 'end=1710547200000000000' \
    --data-urlencode 'limit=1000'

{"status":"error","errorType":"timeout","error":"context deadline exceeded"}

# Even simple queries timeout
$ curl -s "http://localhost:3100/loki/api/v1/query" \
    --data-urlencode 'query={job="containerlogs"}' \
    --data-urlencode 'limit=10'

{"status":"error","errorType":"timeout","error":"the query time range exceeds the limit (query_timeout: 1s)"}

# Label queries work (they're lightweight)
$ curl -s "http://localhost:3100/loki/api/v1/labels"
{"status":"success","data":["__name__","job"]}

# But no actual log streams visible
$ curl -s "http://localhost:3100/loki/api/v1/series" --data-urlencode 'match[]={job=~".+"}'
{"status":"success","data":[]}

# Promtail logs show connection errors
$ docker logs promtail-timeout --tail 20

level=error ts=2024-03-15T12:00:01.000Z caller=client.go:419 
  component=client host=loki:3200 
  msg="error sending batch, will retry" 
  status=0 error="Post \"http://loki:3200/loki/api/v1/push\": dial tcp: connection refused"

level=warn ts=2024-03-15T12:00:02.000Z caller=client.go:379 
  component=client host=loki:3200 
  msg="batch send retries exhausted" 
  status=0 error="Post \"http://loki:3200/loki/api/v1/push\": dial tcp: connection refused"

# Loki ready check passes
$ curl -s http://localhost:3100/ready
ready

# Loki metrics show no ingested streams
$ curl -s http://localhost:3100/metrics | grep loki_ingester_streams_created_total
loki_ingester_streams_created_total 0

# Loki config shows restrictive limits
$ curl -s http://localhost:3100/config | grep -A5 "limits_config"
limits_config:
  query_timeout: 1s
  max_entries_limit_per_query: 100
  ...
```

### Your Task

1. Fix Promtail connectivity (it's sending to the wrong port)
2. Increase query timeouts to usable levels
3. Fix max_entries_limit to allow meaningful results
4. Reduce chunk_target_size so queries don't load excessive data
5. Enable query splitting for large time ranges
6. Enable query result caching
7. Verify end-to-end: logs flowing from generator → Promtail → Loki → Grafana

### Useful Commands

```bash
# Check all service statuses
docker compose ps

# View Loki logs
docker logs loki-timeout --tail 50

# View Promtail logs (shows connection errors)
docker logs promtail-timeout --tail 50

# Check Loki readiness
curl -s http://localhost:3100/ready

# Check Loki metrics
curl -s http://localhost:3100/metrics | grep -E "loki_ingester_(streams|chunks)"

# Query Loki labels
curl -s http://localhost:3100/loki/api/v1/labels

# Test a simple LogQL query
curl -s "http://localhost:3100/loki/api/v1/query" --data-urlencode 'query={job=~".+"}' --data-urlencode 'limit=5'

# Check Loki runtime config
curl -s http://localhost:3100/config | python3 -m json.tool 2>/dev/null || curl -s http://localhost:3100/config

# Check Promtail targets
curl -s http://localhost:9080/targets

# Check Promtail metrics
curl -s http://localhost:9080/metrics | grep promtail_sent

# View current Loki ingestion rate
curl -s http://localhost:3100/metrics | grep loki_distributor_bytes_received_total

# Verify log generators are producing output
docker logs log-generator --tail 5

# Check Grafana datasources
curl -s -u admin:admin http://localhost:3000/api/datasources

# Test Loki from Grafana's perspective
docker exec grafana-loki wget -qO- http://loki:3100/ready

# Force flush Loki ingester
curl -X POST http://localhost:3100/flush
```

### Hints

<details>
<summary>Hint 1</summary>
Promtail is configured to push to `loki:3200` but Loki listens on port `3100`. Fix the `clients.url` in `promtail-config.yml` to use `http://loki:3100/loki/api/v1/push`. After fixing, Promtail will start delivering logs. Check with `curl localhost:9080/targets` after the fix.
</details>

<details>
<summary>Hint 2</summary>
The `limits_config` is the main culprit for query timeouts. Fix these values: `query_timeout: 5m` (from 1s), `max_entries_limit_per_query: 5000` (from 100). Also fix the querier section: `max_concurrent: 10` (from 1), increase `engine.timeout: 5m`. The `http_server_read_timeout` and `http_server_write_timeout` in the server section should be at least `6m` (longer than query_timeout).
</details>

<details>
<summary>Hint 3</summary>
For performance: (1) Reduce `chunk_target_size` from 10MB to `1572864` (1.5MB) — large chunks mean queries load too much data, (2) Add `split_queries_by_interval: 15m` under `limits_config` to break large time range queries into smaller pieces, (3) Enable the results cache: set `embedded_cache.enabled: true` with `max_size_mb: 100`, (4) Set `parallelise_shardable_queries: true` in `query_range`. After all fixes, restart Loki and wait for new logs to arrive.
</details>

---

**Category:** Grafana Loki / Log Aggregation  
**Difficulty:** ⭐⭐⭐⭐⭐ Expert  
**Time Estimate:** 20-30 minutes  
**Skills Tested:** Loki configuration tuning, LogQL query mechanics, chunk lifecycle, Promtail troubleshooting, query performance optimization
