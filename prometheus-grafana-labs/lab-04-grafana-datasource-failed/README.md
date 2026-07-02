## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Prometheus/Grafana via docker-compose)
2. Open Prometheus: http://localhost:9090 → Status → Targets
3. Open Grafana: http://localhost:3000 (admin/admin)
4. Observe what's broken (targets DOWN, alerts not firing, dashboards empty)
5. Fix the configuration files and restart
6. Check `solution.md` if stuck

---

# Lab 04: Grafana Datasource Connection Failed

## Difficulty: ⭐⭐ Medium

## Scenario

Grafana is provisioned with a Prometheus datasource but shows "Datasource is not working" errors.
The team has deployed both services using Docker Compose, but Grafana cannot reach Prometheus.
All dashboards show "No Data" panels despite Prometheus collecting metrics normally.

## Error / Symptom

When you test the datasource in Grafana (Settings → Data Sources → Prometheus → Test):

```
Error: Datasource is not working: Post "http://prometheus:9090/api/v1/query": dial tcp: lookup prometheus on 127.0.0.11:53: no such host
```

- Grafana datasource test returns connection error
- The URL references service name "prometheus" but actual service is "prometheus-server"
- Access mode is set to "direct" (browser-based) instead of "proxy" (server-based)
- With "direct" mode, the browser tries to connect to http://prometheus:9090 which doesn't resolve
- Even if access mode is fixed, the hostname is still wrong
- Dashboards all show "No Data" because queries fail
- Prometheus itself is running fine and collecting metrics at http://localhost:9090

## Hints

1. Check the docker-compose service name — does it match the URL in datasource.yml?
2. Access mode "direct" means the browser makes requests; "proxy" means Grafana server does
3. In Docker networking, services resolve by their compose service name, not container name

## Troubleshooting Commands

```bash
# Test datasource from Grafana container
docker exec grafana-lab04 wget -qO- http://prometheus-server:9090/api/v1/query?query=up 2>&1

# Check what DNS names resolve inside the grafana container
docker exec grafana-lab04 nslookup prometheus-server

# Check Grafana provisioning logs
docker logs grafana-lab04 2>&1 | grep -i "datasource\|error\|provision"

# Verify the provisioned datasource config
docker exec grafana-lab04 cat /etc/grafana/provisioning/datasources/datasource.yml

# Check Grafana datasource API
curl -s -u admin:admin http://localhost:3000/api/datasources | jq '.[].url'
```
