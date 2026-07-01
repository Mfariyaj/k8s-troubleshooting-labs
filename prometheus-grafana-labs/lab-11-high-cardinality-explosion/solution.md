# Lab 11 - High Cardinality Explosion

## Root Cause

The application exposes metrics with unbounded, high-cardinality labels (e.g., user_id,
request_id, session_id). The Prometheus config lacks:
1. `metric_relabel_configs` to drop high-cardinality labels before storage
2. `sample_limit` to cap the number of samples per scrape

## Symptoms

- Prometheus memory usage grows rapidly
- Queries become extremely slow or timeout
- `prometheus_tsdb_head_series` shows millions of series
- Prometheus OOMKilled or crashes

## Fix Steps

1. Open `prometheus.yml`
2. Add `metric_relabel_configs` to drop high-cardinality labels
3. Set `sample_limit` to prevent runaway ingestion

## Corrected Configuration

```yaml
scrape_configs:
  - job_name: 'high-cardinality-app'
    sample_limit: 5000
    static_configs:
      - targets: ['app:8080']
    metric_relabel_configs:
      - regex: '(user_id|request_id|session_id)'
        action: labeldrop
```

## Verification

```bash
# Restart Prometheus
docker-compose restart prometheus

# Check series count is manageable
curl -s 'http://localhost:9090/api/v1/query?query=prometheus_tsdb_head_series'

# Verify sample_limit is enforced (scrapes exceeding limit are dropped)
curl -s 'http://localhost:9090/api/v1/query?query=scrape_samples_scraped'

# Check memory usage stabilizes
curl -s 'http://localhost:9090/api/v1/query?query=process_resident_memory_bytes'
```

## Key Takeaways

- Never use unbounded values (user IDs, request IDs) as metric labels
- `sample_limit` is a safety net against cardinality explosions
- `labeldrop` removes labels after scraping to reduce cardinality
- Monitor `prometheus_tsdb_head_series` for cardinality trends
