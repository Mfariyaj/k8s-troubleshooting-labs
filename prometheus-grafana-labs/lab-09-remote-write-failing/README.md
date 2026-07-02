## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Prometheus/Grafana via docker-compose)
2. Open Prometheus: http://localhost:9090 → Status → Targets
3. Open Grafana: http://localhost:3000 (admin/admin)
4. Observe what's broken (targets DOWN, alerts not firing, dashboards empty)
5. Fix the configuration files and restart
6. Check `solution.md` if stuck

---

# Lab 09: Remote Write Configuration Failing

## Difficulty: ⭐⭐⭐ Hard

## Scenario

Prometheus is configured with remote_write to send metrics to a remote storage backend (Thanos Receive).
After deploying, metrics are not being written remotely — Prometheus logs show 401 auth errors and queue issues.
The operations team needs long-term metrics storage working before the next capacity review.

## Error / Symptom

When you check Prometheus logs:

```
level=warn msg="Error sending batch, retrying" err="server returned HTTP status 401 Unauthorized"
level=warn msg="Remote write queue is full, dropping samples" queue=remote_write
```

- Prometheus logs show 401 Unauthorized errors from the remote endpoint
- The `Authorization` header uses wrong format: `Token` instead of `Bearer`
- The queue_config capacity is set to 10 (extremely small), causing sample drops
- `prometheus_remote_storage_samples_failed_total` counter is increasing rapidly
- `prometheus_remote_storage_queue_highest_sent_timestamp_seconds` is stuck/not advancing
- Remote storage shows zero ingested samples
- Even if auth is fixed, the tiny queue causes constant drops under normal load
- With capacity:10, any slight delay causes immediate backpressure

## Hints

1. Check the `Authorization` header format — remote_write expects `Bearer <token>`, not `Token <token>`
2. The `queue_config.capacity` of 10 is absurdly small — default is 2500, try 1000+ for production
3. Look at `prometheus_remote_storage_*` metrics to see failure rates and queue status

## Troubleshooting Commands

```bash
# Check Prometheus logs for remote write errors
docker logs prometheus-lab09 2>&1 | grep -i "remote\|401\|queue\|unauthorized"

# Check remote storage failed samples counter
curl -s 'http://localhost:9090/api/v1/query?query=prometheus_remote_storage_samples_failed_total' | jq '.data.result[].value[1]'

# Check queue status
curl -s 'http://localhost:9090/api/v1/query?query=prometheus_remote_storage_shards_desired' | jq '.data.result[].value[1]'

# Check the running config
curl -s http://localhost:9090/api/v1/status/config | jq -r '.data.yaml' | grep -A 20 "remote_write"

# Try to manually send a sample to the remote receiver to test auth
curl -v -X POST http://localhost:19291/api/v1/receive -H "Authorization: Bearer correct-token" -d '' 2>&1 | grep "< HTTP"
```
