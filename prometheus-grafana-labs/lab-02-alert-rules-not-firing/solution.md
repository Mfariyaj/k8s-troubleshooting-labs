# Lab 02 - Alert Rules Not Firing

## Root Cause

The alert rules have two issues:
1. `rate()` function is missing the required time range vector selector `[5m]`
2. The comparison operator is wrong (e.g., using `<` instead of `>` or vice versa)

Without the range vector, PromQL returns a syntax error. With the wrong comparison operator,
the alert condition never evaluates to true.

## Symptoms

- Alert rules show as "inactive" and never fire
- Prometheus logs show PromQL evaluation errors
- Rules page shows syntax errors for affected rules

## Fix Steps

1. Open `alert-rules.yml`
2. Add `[5m]` range selector to the `rate()` function
3. Fix the comparison operator to the correct direction

## Corrected Configuration

```yaml
groups:
  - name: example-alerts
    rules:
      - alert: HighRequestRate
        expr: rate(http_requests_total[5m]) > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High request rate detected"
          description: "Request rate is {{ $value }} req/s"
```

## Verification

```bash
# Validate rules file
promtool check rules alert-rules.yml

# Restart Prometheus
docker-compose restart prometheus

# Check rules are loaded without errors
curl -s http://localhost:9090/api/v1/rules | jq '.data.groups[].rules[].lastError'
```

## Key Takeaways

- `rate()` always requires a range vector like `[5m]`
- Use `promtool check rules` to validate rule files before deploying
- Double-check comparison operators match the alert intent
