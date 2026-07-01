# Lab 13: Thanos Sidecar — Block Upload Failures & Data Gaps

## ⭐⭐⭐⭐⭐ Expert Level

### Scenario

Your organization runs a multi-cluster Prometheus setup with Thanos for long-term storage and global querying. The Thanos sidecar should upload completed TSDB blocks to MinIO (S3-compatible object storage), but no blocks are appearing in the bucket. The Thanos Query layer shows gaps in historical data — only real-time data from the sidecar's StoreAPI is available.

Additionally, the Thanos Compactor is throwing errors about duplicate blocks and halting, which means no downsampling is occurring for the 5m and 1h resolution data.

The team has been running blind on historical queries for 3 days. Management wants the global view restored.

### Environment
- Prometheus v2.51.0 with 2h block duration
- Thanos v0.34.1 (sidecar, query, store, compactor)
- MinIO as S3-compatible object storage
- Docker Compose orchestration

### Symptoms

```
# Thanos Sidecar logs — multiple errors
$ docker logs thanos-sidecar --tail 30

level=error ts=2024-03-15T12:00:01.000Z caller=sidecar.go:234 
  msg="no external labels configured for Prometheus" 
  err="no external labels configured in Prometheus server, uniquely identifying external labels must be configured; see https://thanos.io/tip/thanos/storage.md#external-labels for details"

level=warn ts=2024-03-15T12:00:05.000Z caller=sidecar.go:345 
  msg="upload: block upload skipped due to min-time flag" 
  block=01HRF8K2P4WMGJYXNQ7CMVR100 min_time=2024-03-15T10:00:00Z 
  configured_min_time=2099-01-01T00:00:00Z

level=error ts=2024-03-15T12:00:10.000Z caller=shipper.go:456 
  msg="upload: failed to upload block" 
  block=01HRF8K2P4WMGJYXNQ7CMVR100 
  err="upload block: bucket \"thanos-metrics\" does not exist"

level=error ts=2024-03-15T12:01:00.000Z caller=objstore.go:789 
  msg="failed to connect to object storage" 
  err="dial tcp minio:9001: connection refused on API port; endpoint should be :9000"

# Thanos Compactor logs — halted
$ docker logs thanos-compactor --tail 20

level=error ts=2024-03-15T12:02:00.000Z caller=compact.go:123 
  msg="critical error detected; compactor halted" 
  err="compaction: pre-compaction overlap check failed: found duplicate block sources"

level=error ts=2024-03-15T12:02:01.000Z caller=bucket.go:456 
  msg="failed to list bucket objects" 
  err="Get \"http://minio:9001/thanos-metrics/?delimiter=%2F&prefix=\": dial tcp: connection refused"

# Thanos Query — store shows gaps
$ curl -s 'http://localhost:9091/api/v1/query?query=up&time=2024-03-12T12:00:00Z'
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": []
  }
}

# Only real-time data works (from sidecar StoreAPI)
$ curl -s 'http://localhost:9091/api/v1/query?query=up' | jq '.data.result | length'
2

# Thanos Store Gateway has no blocks
$ curl -s http://localhost:10905/api/v1/status
{
  "status": "success",
  "data": {
    "blocks_synced": 0,
    "last_sync_error": "bucket iter: Get \"http://minio:9001/thanos-metrics/...\": connection refused"
  }
}

# MinIO has no bucket
$ docker exec thanos-minio mc ls local/
# (empty — no buckets exist)
```

### Your Task

1. Identify all configuration issues preventing block uploads (there are 5+)
2. Fix the object storage connectivity (bucket, endpoint, credentials)
3. Add required external_labels to Prometheus configuration
4. Fix the sidecar's min-time flag
5. Resolve the compactor/sidecar conflict
6. Verify end-to-end: Prometheus → Sidecar → MinIO → Store → Query

### Useful Commands

```bash
# Check all container statuses
docker compose ps

# View sidecar logs
docker logs thanos-sidecar --tail 50
docker logs thanos-sidecar 2>&1 | grep -i "error\|warn\|upload"

# View compactor logs
docker logs thanos-compactor --tail 50

# Check Prometheus external labels
curl -s localhost:9090/api/v1/status/config | jq -r '.data.yaml' | head -10

# Check Thanos sidecar metrics
curl -s localhost:10902/metrics | grep thanos_shipper

# List MinIO buckets
docker exec thanos-minio mc alias set local http://localhost:9000 minioadmin minioadmin-secret
docker exec thanos-minio mc ls local/

# Create MinIO bucket manually
docker exec thanos-minio mc mb local/thanos-metrics

# Check Thanos Query stores
curl -s localhost:9091/api/v1/stores | jq .

# Verify sidecar can reach Prometheus
docker exec thanos-sidecar wget -qO- http://prometheus:9090/api/v1/status/config

# Check TSDB blocks in Prometheus
docker exec prometheus-thanos ls -la /prometheus/
docker exec prometheus-thanos cat /prometheus/*/meta.json 2>/dev/null

# Validate bucket config YAML
docker exec thanos-sidecar cat /etc/thanos/bucket.yml

# Test MinIO connectivity
docker exec thanos-sidecar wget -qO- http://minio:9000/minio/health/live

# Force Prometheus config reload
curl -X POST localhost:9090/-/reload

# Check Thanos Query targets
curl -s localhost:9091/api/v1/targets | jq .
```

### Hints

<details>
<summary>Hint 1</summary>
Thanos sidecar absolutely requires `external_labels` in `prometheus.yml`. Without them, it refuses to upload blocks because it can't uniquely identify the source. Add `external_labels: {cluster: "production", replica: "prom-0"}` under the `global:` section. After changing, reload Prometheus config.
</details>

<details>
<summary>Hint 2</summary>
The `thanos-bucket.yml` has multiple issues: (1) The bucket name is "thanos-metrics" but no bucket exists in MinIO — create it with `mc mb`, (2) The endpoint port is 9001 (MinIO console) instead of 9000 (S3 API), (3) `access_key` and `secret_key` values are swapped — check the MinIO environment variables in docker-compose.yml and match them correctly.
</details>

<details>
<summary>Hint 3</summary>
The sidecar has `--min-time=2099-01-01T00:00:00Z` which means it will never consider any current block "old enough" to upload. Remove this flag entirely or set it to a past date. Additionally, having both the compactor and sidecar writing to the same bucket can cause duplicate block issues. The compactor's role is to compact/downsample blocks already in the bucket — it should NOT be uploading. Ensure only the sidecar uploads.
</details>

---

**Category:** Thanos / Long-term Storage  
**Difficulty:** ⭐⭐⭐⭐⭐ Expert  
**Time Estimate:** 25-40 minutes  
**Skills Tested:** Thanos architecture, object storage configuration, external labels, block lifecycle, sidecar vs compactor roles, multi-component debugging
