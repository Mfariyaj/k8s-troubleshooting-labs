# Lab 09 - Remote Write Failing

## Root Cause

The remote_write configuration has two issues:
1. Wrong authorization header format - using `Token` prefix instead of `Bearer`
2. Insufficient `queue_config` capacity - the queue fills up causing samples to be dropped

The incorrect auth header causes 401 Unauthorized responses from the remote endpoint.

## Symptoms

- Prometheus logs show `remote_write: 401 Unauthorized` errors
- `prometheus_remote_storage_samples_failed_total` is increasing
- `prometheus_remote_storage_queue_*` metrics show queue full
- Remote storage has gaps in data

## Fix Steps

1. Open `prometheus.yml`
2. Fix the authorization header to use `Bearer` instead of `Token`
3. Increase `queue_config` capacity values

## Corrected Configuration

```yaml
remote_write:
  - url: "http://remote-storage:9009/api/v1/push"
    authorization:
      credentials: "your-api-token-here"
    headers:
      Authorization: "Bearer your-api-token-here"
    queue_config:
      capacity: 10000
      max_shards: 200
      max_samples_per_send: 5000
      batch_send_deadline: 5s
      min_backoff: 30ms
      max_backoff: 5s
```

## Verification

```bash
# Restart Prometheus
docker-compose restart prometheus

# Check for remote write errors
curl -s 'http://localhost:9090/api/v1/query?query=prometheus_remote_storage_samples_failed_total'

# Verify successful sends are increasing
curl -s 'http://localhost:9090/api/v1/query?query=rate(prometheus_remote_storage_samples_total[5m])'

# Check queue is not full
curl -s 'http://localhost:9090/api/v1/query?query=prometheus_remote_storage_shards_desired'
```

## Key Takeaways

- Remote write auth uses `Bearer` token format, not `Token`
- Monitor `prometheus_remote_storage_*` metrics for write health
- Tune `queue_config` based on ingestion rate and network latency
- Use `max_shards` and `capacity` to handle burst traffic
