# Lab 01 - Scrape Config Broken

## Root Cause

The Prometheus scrape configuration has three errors:
1. Wrong port (not 9090)
2. Wrong metrics path (not `/metrics`)
3. Wrong scheme (https instead of http)

These cause Prometheus to fail when scraping targets, resulting in all targets showing as DOWN.

## Symptoms

- Targets page shows all targets as DOWN
- Error messages like "connection refused" or "TLS handshake error"
- No metrics being collected

## Fix Steps

1. Open `prometheus.yml`
2. Fix the `scrape_configs` section:
   - Change port to `9090`
   - Change `metrics_path` to `/metrics`
   - Change `scheme` to `http`

## Corrected Configuration

```yaml
scrape_configs:
  - job_name: 'prometheus'
    scheme: http
    metrics_path: /metrics
    static_configs:
      - targets: ['localhost:9090']
```

## Verification

```bash
# Restart Prometheus with fixed config
docker-compose down && docker-compose up -d

# Check targets are UP
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[].health'

# Verify metrics are being scraped
curl -s http://localhost:9090/api/v1/query?query=up | jq '.data.result'
```

## Key Takeaways

- Default Prometheus metrics endpoint is `http://localhost:9090/metrics`
- Always verify scrape config with `promtool check config prometheus.yml`
- Check the Targets page in Prometheus UI for scrape errors
