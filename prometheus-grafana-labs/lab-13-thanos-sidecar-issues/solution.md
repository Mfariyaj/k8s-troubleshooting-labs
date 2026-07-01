# Lab 13 - Thanos Sidecar Issues

## Root Cause

The Thanos sidecar cannot connect to Prometheus or upload blocks to object storage due to:
1. Missing `external_labels` in Prometheus config (Thanos requires at least one)
2. MinIO bucket does not exist (needs to be created)
3. `thanos-bucket.yml` has wrong credentials and/or port for MinIO

## Symptoms

- Thanos sidecar logs show "no external labels configured"
- Block uploads fail with "bucket not found" or authentication errors
- Thanos Store/Query cannot find any blocks
- `thanos_objstore_bucket_operation_failures_total` increasing

## Fix Steps

1. Add `external_labels` to `prometheus.yml`
2. Create the MinIO bucket
3. Fix `thanos-bucket.yml` with correct credentials and endpoint port

## Corrected Configurations

`prometheus.yml`:
```yaml
global:
  scrape_interval: 15s
  external_labels:
    cluster: "production"
    replica: "prometheus-0"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

`thanos-bucket.yml`:
```yaml
type: S3
config:
  bucket: "thanos"
  endpoint: "minio:9000"
  access_key: "minioadmin"
  secret_key: "minioadmin"
  insecure: true
```

Create the bucket:
```bash
# Using mc (MinIO Client)
mc alias set local http://localhost:9000 minioadmin minioadmin
mc mb local/thanos
```

## Verification

```bash
# Restart services
docker-compose restart prometheus thanos-sidecar

# Check sidecar logs for errors
docker-compose logs thanos-sidecar | tail -20

# Verify sidecar can reach Prometheus
curl -s http://localhost:19090/api/v1/status/config

# Check bucket operations succeed
docker-compose logs thanos-sidecar | grep -i "upload"
```

## Key Takeaways

- Thanos requires at least one `external_label` in Prometheus config
- MinIO bucket must exist before Thanos can upload
- Verify endpoint port (9000 for MinIO API, 9001 for console)
- Use `insecure: true` for non-TLS MinIO setups
