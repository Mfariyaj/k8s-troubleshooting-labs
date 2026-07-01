# Lab 07 - Metric Relabeling Drops All Metrics

## Root Cause

The `metric_relabel_configs` has the wrong action configured. The action is set to `drop`
when it should be `keep`, or the regex is too broad and matches all metrics instead of
targeting only specific unwanted ones.

This causes Prometheus to drop all (or most) scraped metrics, resulting in empty queries.

## Symptoms

- Targets show as UP with successful scrapes
- But queries return no data
- `scrape_samples_scraped` shows 0 or very low numbers
- Metrics that should exist are missing

## Fix Steps

1. Open `prometheus.yml`
2. In the `metric_relabel_configs` section, either:
   - Change `action: drop` to `action: keep` (if you want to keep matching metrics)
   - Fix the regex to target only specific metrics you want to drop

## Corrected Configuration

Option A - Keep desired metrics:
```yaml
scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:8080']
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: '(http_requests_total|process_.*|go_.*)'
        action: keep
```

Option B - Drop only specific unwanted metrics:
```yaml
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: '(go_gc_.*|promhttp_.*)'
        action: drop
```

## Verification

```bash
# Restart Prometheus
docker-compose restart prometheus

# Check that metrics are being retained
curl -s 'http://localhost:9090/api/v1/query?query=up' | jq '.data.result'

# Verify scrape samples count
curl -s 'http://localhost:9090/api/v1/query?query=scrape_samples_scraped' | jq

# List available metrics
curl -s http://localhost:9090/api/v1/label/__name__/values | jq '.data | length'
```

## Key Takeaways

- `drop` removes matching metrics; `keep` removes everything that does NOT match
- A broad regex with `drop` action can accidentally remove all metrics
- Always verify with `scrape_samples_scraped` after relabeling changes
- Test regex patterns against known metric names before deploying
