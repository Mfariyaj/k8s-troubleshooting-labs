# Lab 10 - Dashboard Variables Not Working

## Root Cause

The Grafana dashboard JSON has three issues with template variables:
1. Datasource UID does not match the actual provisioned datasource UID
2. Regex patterns do not escape dots (`.` matches any character in regex)
3. Variable query expression is incorrect (wrong label or metric name)

## Symptoms

- Dashboard variables show empty dropdowns
- Panels display "No Data" even when metrics exist
- Variable refresh returns errors in browser console

## Fix Steps

1. Open `dashboard.json`
2. Fix datasource UID to match the actual datasource (check `datasource.yml`)
3. Escape dots in regex: use `\\.` instead of `.`
4. Fix variable query to use correct PromQL label_values() syntax

## Corrected Configuration

In `datasource.yml`, ensure a consistent UID:
```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    uid: prometheus-ds
    url: http://prometheus:9090
    access: proxy
    isDefault: true
```

In `dashboard.json`, fix the variable:
```json
{
  "templating": {
    "list": [
      {
        "name": "instance",
        "type": "query",
        "datasource": {
          "type": "prometheus",
          "uid": "prometheus-ds"
        },
        "query": "label_values(up, instance)",
        "regex": "/([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+):.*/",
        "refresh": 1
      }
    ]
  }
}
```

## Verification

```bash
# Restart Grafana
docker-compose restart grafana

# Check datasource UID
curl -s -u admin:admin http://localhost:3000/api/datasources | jq '.[].uid'

# Test variable query
curl -s -u admin:admin 'http://localhost:3000/api/datasources/proxy/1/api/v1/label/instance/values'
```

## Key Takeaways

- Datasource UIDs must match between dashboard JSON and provisioning config
- Regex in Grafana uses standard regex - escape special characters like `.`
- Use `label_values(metric, label)` for variable queries
- Test variable queries in Grafana Explore tab first
