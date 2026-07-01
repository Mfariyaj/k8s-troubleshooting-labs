# Lab 10: Dashboard Template Variables Not Working

## Difficulty: ⭐⭐⭐ Hard

## Scenario

A Grafana dashboard with template variables is provisioned automatically but shows empty dropdowns.
The dashboard uses Prometheus as a datasource with variable queries to populate job and instance selectors.
Despite Prometheus having data, the variables show no values and panels display "No Data."

## Error / Symptom

When you open the dashboard in Grafana at http://localhost:3000:

```
Variable "job": Error: Datasource WRONG-UID-12345 not found
Variable "instance": Error: Datasource WRONG-UID-12345 not found
Panel "CPU Usage by Instance": Datasource prometheus-ds not found
```

- Both template variables show "Error" state with empty dropdowns
- The variable queries reference datasource UID `WRONG-UID-12345` but actual UID is `prom-ds-01`
- Panel targets reference datasource UID `prometheus-ds` which also doesn't match
- The instance variable has a regex filter `/.*(.+.example.com).*/` with unescaped dots
- The unescaped dots in the regex cause the filter to match unexpected patterns or nothing
- Even if UIDs are fixed, the regex filter may still hide valid instances like `node-exporter:9100`
- The regex should use `\.` instead of `.` for literal dots, or be removed entirely
- All panels show "No Data" due to cascading variable failures

## Hints

1. The datasource UID in dashboard.json must match the UID defined in datasource.yml provisioning
2. Check all three places UIDs are referenced: variable datasource, panel datasource, and target datasource
3. The regex `/.*(.+.example.com).*/` has unescaped dots (`.` matches any char) and may filter out all valid values

## Troubleshooting Commands

```bash
# Check provisioned datasource UID
curl -s -u admin:admin http://localhost:3000/api/datasources | jq '.[].uid'

# Check dashboard variables
curl -s -u admin:admin http://localhost:3000/api/dashboards/uid/broken-vars-dashboard | jq '.dashboard.templating.list[].datasource'

# Check if Prometheus actually has data
curl -s 'http://localhost:9090/api/v1/query?query=up' | jq '.data.result[].metric'

# Check Grafana logs for datasource errors
docker logs grafana-lab10 2>&1 | grep -i "datasource\|uid\|error\|variable"

# List available label values from Prometheus
curl -s 'http://localhost:9090/api/v1/label/job/values' | jq .
```
