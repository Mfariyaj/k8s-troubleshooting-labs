# Lab 07: Metric Relabeling Drops All Metrics

## Difficulty: ⭐⭐ Medium

## Scenario

Your team added metric_relabel_configs to Prometheus to reduce storage by dropping unnecessary metrics.
After deploying, all dashboards suddenly show no data — even basic metrics like `up` are missing.
Targets appear healthy (UP state) but zero time series are being stored.

## Error / Symptom

When you query the expression browser at http://localhost:9090/graph:

```
Query: up
Result: Empty query result
```

```
Query: node_cpu_seconds_total
Result: Empty query result
```

- All targets show as UP on the /targets page
- But ZERO time series are stored — every query returns empty
- `prometheus_tsdb_head_series` shows 0 (or a tiny number)
- The metric_relabel_configs regex `'.*'` matches EVERY metric name
- With action: drop, this means every scraped metric is discarded after collection
- Scrapes succeed (target is UP) but metrics are dropped before storage
- The intended behavior was to drop a specific set of metrics, not all
- Multiple relabel rules are processed in order — the first `drop` rule catches everything

## Hints

1. `metric_relabel_configs` with `action: drop` removes metrics AFTER scraping but BEFORE storage
2. The regex `'.*'` matches every string — including all metric names
3. If you want to drop specific metrics, use a specific regex like `node_cpu_guest_.*` not `.*`

## Troubleshooting Commands

```bash
# Check if targets are UP (they will be - that's the confusing part)
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'

# Try querying for any metric - should be empty
curl -s 'http://localhost:9090/api/v1/query?query=up' | jq '.data.result | length'

# Check total time series in TSDB
curl -s 'http://localhost:9090/api/v1/query?query=prometheus_tsdb_head_series' | jq '.data.result[].value[1]'

# Verify node-exporter IS actually serving metrics
docker exec node-exporter-lab07 wget -qO- http://localhost:9100/metrics | wc -l

# Check the prometheus config to see relabel rules
docker exec prometheus-lab07 cat /etc/prometheus/prometheus.yml
```
