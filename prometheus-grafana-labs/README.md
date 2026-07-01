# 📊 Prometheus & Grafana Troubleshooting Labs

## 10 Real-World Broken Scenarios for Monitoring Engineers

---

## Overview

These labs present intentionally broken Prometheus and Grafana configurations that simulate real production monitoring failures. Each lab requires you to diagnose and fix issues using only CLI tools, the Prometheus/Grafana APIs, and your observability expertise.

---

## 🗂️ Lab Index

| # | Lab | Difficulty | Key Issue |
|---|-----|-----------|-----------|
| 01 | [Scrape Config Broken](lab-01-scrape-config-broken/) | ⭐ Easy | Wrong port, path, and scheme in scrape target |
| 02 | [Alert Rules Not Firing](lab-02-alert-rules-not-firing/) | ⭐⭐ Medium | Invalid PromQL in alert expressions |
| 03 | [Service Discovery RBAC](lab-03-service-discovery-rbac/) | ⭐⭐⭐ Hard | Missing K8s RBAC permissions for SD |
| 04 | [Grafana Datasource Failed](lab-04-grafana-datasource-failed/) | ⭐⭐ Medium | Wrong URL and access mode in datasource |
| 05 | [Recording Rules Syntax](lab-05-recording-rules-syntax/) | ⭐⭐ Medium | Syntax errors and duplicate groups |
| 06 | [Federation Broken](lab-06-federation-broken/) | ⭐⭐⭐ Hard | Missing match[] and wrong honor_labels |
| 07 | [Metric Relabeling Drops](lab-07-metric-relabeling-drops/) | ⭐⭐ Medium | Overly broad regex drops all metrics |
| 08 | [Alertmanager Routing](lab-08-alertmanager-routing/) | ⭐⭐⭐ Hard | Receiver name mismatch and missing continue |
| 09 | [Remote Write Failing](lab-09-remote-write-failing/) | ⭐⭐⭐ Hard | Wrong auth header and tiny queue capacity |
| 10 | [Dashboard Variables](lab-10-dashboard-variables/) | ⭐⭐⭐ Hard | Datasource UID mismatch and broken regex |

---

## 🚀 Quick Start

### Deploy a single lab:
```bash
cd lab-01-scrape-config-broken
./deploy.sh
```

### Deploy all labs (⚠️ port conflicts — use one at a time):
```bash
./deploy.sh
```

### Clean up a single lab:
```bash
cd lab-01-scrape-config-broken
./cleanup.sh
```

### Clean up all labs:
```bash
./cleanup.sh
```

---

## 📋 Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Docker | 20.10+ | Container runtime |
| Docker Compose | 2.0+ | Multi-container orchestration |
| curl | any | API testing |
| jq | 1.6+ | JSON parsing |
| kubectl | 1.25+ | Lab 03 (Kubernetes RBAC) only |

---

## 🏗️ Lab Structure

Each lab directory contains:

```
lab-XX-name/
├── README.md              # Scenario, symptoms, hints, commands
├── deploy.sh              # Deploys the broken environment
├── cleanup.sh             # Tears down the environment
├── docker-compose.yml     # Service definitions
├── prometheus.yml         # Prometheus configuration (broken)
└── [additional files]     # Alert rules, dashboards, etc.
```

---

## 📊 Progress Tracker

| Lab | Status | Time |
|-----|--------|------|
| ☐ Lab 01: Scrape Config Broken | _ | _ min |
| ☐ Lab 02: Alert Rules Not Firing | _ | _ min |
| ☐ Lab 03: Service Discovery RBAC | _ | _ min |
| ☐ Lab 04: Grafana Datasource Failed | _ | _ min |
| ☐ Lab 05: Recording Rules Syntax | _ | _ min |
| ☐ Lab 06: Federation Broken | _ | _ min |
| ☐ Lab 07: Metric Relabeling Drops | _ | _ min |
| ☐ Lab 08: Alertmanager Routing | _ | _ min |
| ☐ Lab 09: Remote Write Failing | _ | _ min |
| ☐ Lab 10: Dashboard Variables | _ | _ min |

---

## 💡 Tips

- **Start with the logs**: `docker logs <container>` reveals 90% of configuration issues
- **Use promtool**: `promtool check config` and `promtool check rules` validate before deploying
- **Use amtool**: `amtool check-config` validates Alertmanager configuration
- **Hit the APIs**: Prometheus `/api/v1/targets`, `/api/v1/rules`, `/api/v1/status/config`
- **Check Grafana API**: `curl -u admin:admin http://localhost:3000/api/datasources`
- **Think about connectivity**: In Docker, services resolve by compose service name
- **Read error messages carefully**: They usually tell you exactly what's wrong

---

## ⚔️ Rules of Engagement

1. Deploy the lab → investigate using CLI only → identify root cause → fix it
2. Don't read the config files before deploying — diagnose from symptoms
3. Time yourself — aim for under 10 minutes per lab
4. Use the hints only if stuck for more than 5 minutes
5. Document what broke and how you fixed it

---

## 📜 License

MIT License — break things freely, fix them wisely.
