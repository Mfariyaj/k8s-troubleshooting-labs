# Lab 12 - WAL Corruption

## Root Cause

Prometheus was killed with SIGKILL (or experienced a hard crash) instead of graceful
SIGTERM shutdown. This corrupted the Write-Ahead Log (WAL), preventing Prometheus from
starting up. The fix requires:
1. Using SIGTERM for graceful shutdown going forward
2. Repairing the corrupted WAL with `promtool tsdb repair`

## Symptoms

- Prometheus fails to start with "WAL" or "corruption" errors in logs
- Log messages like "err opening WAL" or "invalid chunk"
- Container enters crash loop on restart
- Data directory shows corrupted WAL segments

## Fix Steps

1. Stop Prometheus (if running)
2. Run `promtool tsdb repair` on the data directory to fix WAL corruption
3. Restart Prometheus
4. Ensure future shutdowns use SIGTERM (not SIGKILL)

## Fix Commands

```bash
# Stop the container
docker-compose stop prometheus

# Repair the WAL
docker run --rm -v $(pwd)/prometheus-data:/prometheus \
  prom/prometheus:latest \
  promtool tsdb repair /prometheus

# Or if promtool is available locally:
promtool tsdb repair ./prometheus-data

# Restart with graceful shutdown configured
docker-compose up -d prometheus
```

Ensure `docker-compose.yml` uses proper stop signal:
```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    stop_signal: SIGTERM
    stop_grace_period: 30s
```

## Verification

```bash
# Check Prometheus starts successfully
docker-compose logs prometheus | tail -20

# Verify TSDB is healthy
curl -s http://localhost:9090/api/v1/status/tsdb | jq '.status'

# Confirm metrics are being scraped again
curl -s 'http://localhost:9090/api/v1/query?query=up'
```

## Key Takeaways

- Always use SIGTERM (not SIGKILL) for Prometheus shutdown
- `promtool tsdb repair` can recover from WAL corruption
- Set `stop_grace_period` in Docker to allow time for graceful flush
- Regular TSDB snapshots provide a recovery fallback
