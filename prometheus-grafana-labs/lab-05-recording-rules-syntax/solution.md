# Lab 05 - Recording Rules Syntax Errors

## Root Cause

The recording rules file has three syntax issues:
1. Mismatched parentheses in PromQL expressions
2. Trailing commas in YAML that cause parse errors
3. Duplicate group names (Prometheus requires unique group names)

## Symptoms

- Prometheus fails to start or reload config
- Logs show "error loading rule group" or YAML parse errors
- Rules page is empty or shows evaluation errors
- `promtool check rules` reports syntax failures

## Fix Steps

1. Open `recording-rules.yml`
2. Fix mismatched parentheses in `expr` fields
3. Remove trailing commas from YAML lines
4. Rename one of the duplicate groups to a unique name

## Corrected Configuration

```yaml
groups:
  - name: node_recording_rules
    rules:
      - record: node:cpu_utilization:ratio
        expr: (1 - avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])))
      - record: node:memory_utilization:ratio
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))

  - name: http_recording_rules
    rules:
      - record: job:http_requests:rate5m
        expr: sum by(job) (rate(http_requests_total[5m]))
      - record: job:http_request_duration:p99
        expr: histogram_quantile(0.99, sum by(le, job) (rate(http_request_duration_seconds_bucket[5m])))
```

## Verification

```bash
# Validate rules syntax
promtool check rules recording-rules.yml

# Restart Prometheus
docker-compose restart prometheus

# Check rules are loaded
curl -s http://localhost:9090/api/v1/rules | jq '.data.groups[].name'

# Query a recording rule result
curl -s 'http://localhost:9090/api/v1/query?query=node:cpu_utilization:ratio'
```

## Key Takeaways

- Always validate with `promtool check rules` before deploying
- YAML does not allow trailing commas
- Group names must be unique within a rules file
- Match every opening parenthesis with a closing one in PromQL
