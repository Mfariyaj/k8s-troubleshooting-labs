# Lab 08 - Alertmanager Routing Misconfigured

## Root Cause

The Alertmanager configuration has three routing issues:
1. Receiver name mismatch - config references `slack-team` but receiver is defined as `slack_team`
2. Missing `continue: true` on routes - alerts stop at first match and never reach subsequent routes
3. Incorrect `match` labels - route matchers don't match actual alert labels

## Symptoms

- Alerts fire in Prometheus but notifications never arrive
- Alertmanager logs show "receiver not found" errors
- Some alerts go to the wrong channel
- Critical alerts absorbed by catch-all route

## Fix Steps

1. Open `alertmanager.yml`
2. Fix receiver name to match exactly: use `slack_team` (underscores)
3. Add `continue: true` to routes that should pass alerts to multiple receivers
4. Fix match labels to correspond with actual alert labels

## Corrected Configuration

```yaml
route:
  receiver: 'default'
  group_by: ['alertname', 'cluster']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  routes:
    - match:
        severity: critical
      receiver: 'slack_team'
      continue: true
    - match:
        severity: warning
      receiver: 'slack_team'

receivers:
  - name: 'default'
    webhook_configs:
      - url: 'http://localhost:5001/'
  - name: 'slack_team'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/XXX'
        channel: '#alerts'
```

## Verification

```bash
# Validate Alertmanager config
amtool check-config alertmanager.yml

# Restart Alertmanager
docker-compose restart alertmanager

# Test routing with amtool
amtool config routes test --config.file=alertmanager.yml severity=critical

# Verify alerts are being routed
curl -s http://localhost:9093/api/v2/alerts | jq '.[].status'
```

## Key Takeaways

- Receiver names are case/character-sensitive (hyphen != underscore)
- `continue: true` allows an alert to match multiple routes
- Use `amtool check-config` and `amtool config routes test` to validate
