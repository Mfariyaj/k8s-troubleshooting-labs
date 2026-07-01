# Lab 01: Broken Scrape Configuration

## Difficulty: ⭐ Easy

## Scenario

You've just deployed Prometheus alongside a node-exporter to monitor system metrics.
Prometheus starts successfully but reports all node-exporter targets as DOWN.
Your team needs these metrics for capacity planning dashboards that are now empty.

## Error / Symptom

When you check the Prometheus targets page at http://localhost:9090/targets, you'll observe:

```
node-exporter target is DOWN
Last scrape error: "Get https://node-exporter:9091/metric: dial tcp connect: connection refused"
```

- The node-exporter target shows state DOWN
- Scrape error mentions TLS/HTTPS connection failure
- The metrics path shows `/metric` instead of the expected `/metrics`
- The port 9091 doesn't match node-exporter's default port (9100)
- Prometheus itself (localhost:9090) scrapes fine
- No node_* metrics appear in the expression browser
- Grafana dashboards relying on node metrics show "No Data"

## Hints

1. Check what port node-exporter actually listens on (hint: it's not 9091)
2. Look at the metrics_path — does Prometheus use `/metric` or `/metrics`?
3. Does node-exporter serve metrics over HTTPS by default, or plain HTTP?

## Troubleshooting Commands

```bash
# Check target status
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health, lastError: .lastError}'

# Verify node-exporter is actually running and on which port
docker exec node-exporter-lab01 wget -qO- http://localhost:9100/metrics | head -5

# Check Prometheus config
docker exec prometheus-lab01 cat /etc/prometheus/prometheus.yml

# Check Prometheus logs for scrape errors
docker logs prometheus-lab01 2>&1 | grep -i "error\|scrape"

# Try to reach node-exporter from prometheus container
docker exec prometheus-lab01 wget -qO- http://node-exporter:9100/metrics | head -5
```
