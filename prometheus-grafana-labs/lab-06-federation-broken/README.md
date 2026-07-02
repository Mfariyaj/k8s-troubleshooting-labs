## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Prometheus/Grafana via docker-compose)
2. Open Prometheus: http://localhost:9090 → Status → Targets
3. Open Grafana: http://localhost:3000 (admin/admin)
4. Observe what's broken (targets DOWN, alerts not firing, dashboards empty)
5. Fix the configuration files and restart
6. Check `solution.md` if stuck

---

# Lab 06: Federation Configuration Broken

## Difficulty: ⭐⭐⭐ Hard

## Scenario

Your organization runs a federated Prometheus setup with a primary instance that scrapes from regional instances.
The federated instance collects metrics from node-exporter, but the primary cannot pull metrics from it.
The federation scrape job either returns no data or overwrites label metadata incorrectly.

## Error / Symptom

When you check the primary Prometheus at http://localhost:9090/targets:

```
federate target: http://prometheus-federated:9091/federate
State: UP (but returning empty results)
Last scrape: 0 samples
```

Or you may see:
```
"error": "no match[] parameter provided"
```

- The /federate endpoint requires `match[]` query parameters but none are configured
- Without match[] params, federation returns HTTP 400 or empty results
- honor_labels is set to false, which means the primary overwrites original `job` and `instance` labels
- Metrics from the federated instance lose their original labeling context
- The primary's expression browser shows federated metrics with wrong/conflicting labels
- curl to the federation endpoint without match[] returns an error
- Setting honor_labels:false causes label conflicts when aggregating across instances

## Hints

1. The /federate endpoint REQUIRES at least one `match[]` parameter to select which metrics to expose
2. `honor_labels: true` preserves labels from the remote instance; `false` overwrites them with the scrape job's labels
3. Check the Prometheus federation docs — the params section needs `'match[]': ['{job=~".+"}']` format

## Troubleshooting Commands

```bash
# Try hitting the federate endpoint directly (should fail without match[])
curl -s 'http://localhost:9091/federate' 2>&1

# Try with correct match param (should work)
curl -s 'http://localhost:9091/federate?match[]={job=~".%2B"}' | head -20

# Check primary prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job=="federate")'

# Check what metrics the primary has from federation
curl -s 'http://localhost:9090/api/v1/query?query={job="federate"}' | jq '.data.result | length'

# View primary Prometheus logs for federation errors
docker logs prometheus-primary-lab06 2>&1 | grep -i "federate\|error\|scrape"
```
