## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Prometheus/Grafana via docker-compose)
2. Open Prometheus: http://localhost:9090 → Status → Targets
3. Open Grafana: http://localhost:3000 (admin/admin)
4. Observe what's broken (targets DOWN, alerts not firing, dashboards empty)
5. Fix the configuration files and restart
6. Check `solution.md` if stuck

---

# Lab 02: Alert Rules Not Firing

## Difficulty: ⭐⭐ Medium

## Scenario

Your team has configured Prometheus alert rules to detect high CPU usage, high memory usage, and instance downtime.
After deploying, no alerts are ever firing despite clearly exceeding thresholds.
Prometheus may fail to start or show rule evaluation errors on the /alerts page.

## Error / Symptom

When you navigate to http://localhost:9090/alerts, you'll observe:

```
Error evaluating rule: 1:6: parse error: expected type range vector in call to function "rate", got instant vector
```

- Prometheus may refuse to start entirely due to invalid rule syntax
- If it starts, the /alerts page shows evaluation errors for HighCPUUsage and InstanceDown
- The HighMemoryUsage alert uses `>=` which means it fires at exactly 80% (too sensitive)
- The InstanceDown alert applies `rate()` to a gauge metric (`up`), which is semantically wrong
- rate() requires a range vector like `[5m]` but receives an instant vector
- No alerts are delivered to Alertmanager
- The Alertmanager UI at :9093 shows zero active alerts

## Hints

1. `rate()` requires a range vector selector — you need `[duration]` in the expression
2. The `up` metric is a gauge (0 or 1), not a counter — rate() doesn't apply to it
3. Think about the threshold operators: when should an alert fire vs stay silent?

## Troubleshooting Commands

```bash
# Check if Prometheus started successfully
docker logs prometheus-lab02 2>&1 | grep -i "error\|rule"

# Validate rules file syntax using promtool
docker exec prometheus-lab02 promtool check rules /etc/prometheus/alert-rules.yml

# Check alert status via API
curl -s http://localhost:9090/api/v1/alerts | jq .

# Check rule groups and their evaluation status
curl -s http://localhost:9090/api/v1/rules | jq '.data.groups[].rules[] | {name: .name, health: .health, lastError: .lastError}'

# Check Alertmanager for received alerts
curl -s http://localhost:9093/api/v2/alerts | jq .
```
