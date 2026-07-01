# Lab 04 - Grafana Datasource Connection Failed

## Root Cause

The Grafana datasource provisioning file has two issues:
1. The URL is wrong - should be `http://prometheus-server:9090` (using Docker service name)
2. The access mode is incorrect - should be `proxy` (server-side) not `direct` (browser-side)

With `direct` access, Grafana tells the browser to query Prometheus directly, which fails
because the browser cannot resolve internal Docker network hostnames.

## Symptoms

- Grafana shows "Data source is not working" error
- Dashboards display "No Data" for all panels
- Testing datasource in Grafana UI returns connection error

## Fix Steps

1. Open `datasource.yml`
2. Fix the URL to `http://prometheus-server:9090` (or the correct service name)
3. Change access mode to `proxy`

## Corrected Configuration

```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus-server:9090
    isDefault: true
    editable: true
```

## Verification

```bash
# Restart Grafana to reload provisioning
docker-compose restart grafana

# Test datasource via Grafana API
curl -s -u admin:admin http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=up

# Or use Grafana UI: Configuration > Data Sources > Prometheus > "Save & Test"
```

## Key Takeaways

- Use Docker service names (not localhost) for inter-container communication
- `proxy` mode = Grafana server queries the datasource (correct for most setups)
- `direct` mode = browser queries the datasource (rarely appropriate)
- Verify network connectivity between containers with `docker exec`
