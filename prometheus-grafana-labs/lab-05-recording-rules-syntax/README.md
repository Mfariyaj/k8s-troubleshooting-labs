# Lab 05: Recording Rules Syntax Errors

## Difficulty: ⭐⭐ Medium

## Scenario

Your team has written Prometheus recording rules to pre-compute expensive queries for dashboards.
After deploying, Prometheus refuses to start or shows rule evaluation errors.
The recording rules file contains multiple syntax errors that must be found and fixed.

## Error / Symptom

When Prometheus tries to load the rules file:

```
ts=... caller=main.go level=error msg="Error loading config (--config.file=/etc/prometheus/prometheus.yml)"
err="error parsing /etc/prometheus/recording-rules.yml: 1:6: group \"node_recording_rules\" repeated in file"
```

```
parse error: unclosed left parenthesis
parse error: unexpected ")" in grouping opts
```

- Prometheus fails to start entirely due to invalid rule file
- Duplicate group name "node_recording_rules" appears twice in the same file
- The `node:cpu:usage_ratio` expression has unmatched parentheses
- The `instance:http_requests:rate5m` expression has trailing commas causing parse errors
- `promtool check rules` will report multiple errors
- Even if one error is fixed, others prevent loading
- No recording rules are evaluated, dependent dashboards show stale data

## Hints

1. Use `promtool check rules recording-rules.yml` to validate syntax before deploying
2. Group names must be unique within the same file — rename or merge duplicate groups
3. Check for unmatched parentheses and trailing commas in PromQL expressions

## Troubleshooting Commands

```bash
# Check why Prometheus won't start
docker logs prometheus-lab05 2>&1 | tail -20

# Validate rules syntax with promtool
docker run --rm -v $(pwd)/recording-rules.yml:/rules.yml prom/prometheus:v2.47.0 promtool check rules /rules.yml

# Check if Prometheus is running at all
docker ps -a --filter name=prometheus-lab05

# Try to load config and see detailed errors
docker exec prometheus-lab05 promtool check config /etc/prometheus/prometheus.yml 2>&1

# Check Prometheus runtime status
curl -s http://localhost:9090/api/v1/status/config | jq .status
```
