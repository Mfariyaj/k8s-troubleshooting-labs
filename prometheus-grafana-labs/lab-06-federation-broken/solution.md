# Lab 06 - Federation Broken

## Root Cause

The federation scrape configuration has two issues:
1. Missing `honor_labels: true` - without this, the federating Prometheus overwrites labels
   from the source, causing metric conflicts and identity issues
2. Missing `match[]` parameters on the `/federate` endpoint - without these, the endpoint
   returns no metrics (it requires explicit matchers)

## Symptoms

- Federation target shows as UP but no metrics are collected
- Querying federated metrics returns empty results
- Labels from source Prometheus are overwritten with incorrect values
- `/federate` endpoint returns empty response

## Fix Steps

1. Open `prometheus-primary.yml` (the federating Prometheus config)
2. Add `honor_labels: true` to the federation scrape job
3. Add `match[]` params to the federation endpoint using `params` section

## Corrected Configuration

```yaml
scrape_configs:
  - job_name: 'federate'
    scrape_interval: 15s
    honor_labels: true
    metrics_path: /federate
    params:
      'match[]':
        - '{job=~".+"}'
        - '{__name__=~"job:.*"}'
    static_configs:
      - targets:
          - 'prometheus-federated:9090'
```

## Verification

```bash
# Restart Prometheus
docker-compose restart

# Check federation target is UP
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job=="federate")'

# Verify federated metrics exist
curl -s 'http://localhost:9090/api/v1/query?query={job=~".+"}' | jq '.data.result | length'

# Test federation endpoint directly
curl -s 'http://prometheus-federated:9090/federate?match[]={job=~".+"}'
```

## Key Takeaways

- `honor_labels: true` is mandatory for federation to preserve source labels
- The `/federate` endpoint requires at least one `match[]` parameter
- Use `params` in scrape config to pass query parameters
