# Lab 14 - Loki LogQL Timeout

## Root Cause

The Loki + Promtail stack has three configuration issues:
1. `query_timeout` in Loki is too low for large log queries (needs 120s)
2. `max_entries` limit is too restrictive, truncating results
3. Promtail port is misconfigured - should be `3100` (Loki's API port)

## Symptoms

- LogQL queries return "context deadline exceeded" errors
- Query results are truncated with "limit reached" warnings
- Promtail logs show connection refused when pushing to Loki
- Grafana Explore shows timeout errors for log queries

## Fix Steps

1. Open `loki-config.yml` and increase `query_timeout` to `120s`
2. Increase `max_entries_limit_per_query` in Loki limits config
3. Open `promtail-config.yml` and fix the Loki push URL port to `3100`

## Corrected Configurations

`loki-config.yml`:
```yaml
server:
  http_listen_port: 3100

limits_config:
  max_entries_limit_per_query: 10000
  query_timeout: 120s

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
```

`promtail-config.yml`:
```yaml
clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log
```

## Verification

```bash
# Restart services
docker-compose restart loki promtail

# Test Loki is accepting logs
curl -s http://localhost:3100/ready

# Run a LogQL query
curl -s 'http://localhost:3100/loki/api/v1/query_range?query={job="varlogs"}&limit=100'

# Check Promtail is pushing successfully
docker-compose logs promtail | grep -i "error"
```

## Key Takeaways

- Default Loki query timeout is often too low for production log volumes
- Increase `max_entries_limit_per_query` for queries needing more results
- Loki default API port is 3100 - ensure Promtail pushes to the correct port
- Monitor `loki_request_duration_seconds` for query performance
