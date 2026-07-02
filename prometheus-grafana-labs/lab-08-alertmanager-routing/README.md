## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Prometheus/Grafana via docker-compose)
2. Open Prometheus: http://localhost:9090 → Status → Targets
3. Open Grafana: http://localhost:3000 (admin/admin)
4. Observe what's broken (targets DOWN, alerts not firing, dashboards empty)
5. Fix the configuration files and restart
6. Check `solution.md` if stuck

---

# Lab 08: Alertmanager Routing Misconfiguration

## Difficulty: ⭐⭐⭐ Hard

## Scenario

Your alerting pipeline sends alerts from Prometheus to Alertmanager for routing to different teams.
After deploying, Alertmanager refuses to start due to configuration errors.
Even if forced past startup, alerts are not routed to the correct receivers.

## Error / Symptom

When Alertmanager starts, you'll see:

```
level=error msg="Loading configuration file failed" file=/etc/alertmanager/alertmanager.yml 
err="undefined receiver \"slack-team\" used in route"
```

- Alertmanager fails to start because the default route references receiver 'slack-team'
- But the receiver is defined as 'slack_team' (underscore vs hyphen mismatch)
- Even after fixing the name, alerts for team=backend with severity=critical don't reach pagerduty_team
- The second route catches team=backend alerts but doesn't have `continue: true`
- This means the third route (matching severity=critical) is never evaluated for backend alerts
- Critical backend alerts only go to pagerduty_team via the team match, missing the severity route
- Frontend alerts reference the wrong receiver name too
- `amtool check-config` will catch the receiver name mismatch

## Hints

1. Receiver names in routes must EXACTLY match names in the receivers section (check hyphens vs underscores)
2. `continue: true` on a route means matching continues to subsequent sibling routes
3. Without `continue`, once an alert matches a route, no further sibling routes are evaluated

## Troubleshooting Commands

```bash
# Check if Alertmanager started
docker logs alertmanager-lab08 2>&1 | head -20

# Validate config with amtool
docker exec alertmanager-lab08 amtool check-config /etc/alertmanager/alertmanager.yml

# Check active alerts in Alertmanager
curl -s http://localhost:9093/api/v2/alerts | jq '.[].labels'

# Check routing tree
docker exec alertmanager-lab08 amtool config routes --config.file=/etc/alertmanager/alertmanager.yml

# Test routing for a specific alert
docker exec alertmanager-lab08 amtool config routes test --config.file=/etc/alertmanager/alertmanager.yml team=backend severity=critical
```
