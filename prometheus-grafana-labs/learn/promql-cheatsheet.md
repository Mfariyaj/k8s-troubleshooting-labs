# 📊 PromQL Cheat Sheet — All Common Queries

## Quick Reference for Prometheus Query Language

---

## 🟢 Basic Queries

```promql
# Is my target alive? (1=up, 0=down)
up

# Filter by job name
up{job="node-exporter"}

# All metrics for a specific job
{job="prometheus"}

# Search metric names (regex)
{__name__=~"node_cpu.*"}
```

---

## 📈 Counters (Total counts — only go UP)

```promql
# Total HTTP requests
http_requests_total

# Request rate (per second over 5 min)
rate(http_requests_total[5m])

# Request rate for specific endpoint
rate(http_requests_total{method="GET", endpoint="/api/users"}[5m])

# Total requests in last 1 hour
increase(http_requests_total[1h])

# Instant rate (last 2 data points — more spiky)
irate(http_requests_total[5m])
```

---

## 📉 Gauges (Current value — goes UP and DOWN)

```promql
# Current active connections
node_netstat_Tcp_CurrEstab

# Current memory usage
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# Temperature, queue size, active users
app_active_users
```

---

## ⏱️ Histograms (Latency/Duration percentiles)

```promql
# 50th percentile (median) latency
histogram_quantile(0.5, rate(http_request_duration_seconds_bucket[5m]))

# 90th percentile latency
histogram_quantile(0.90, rate(http_request_duration_seconds_bucket[5m]))

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# 99th percentile latency
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))

# Average request duration
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])
```

---

## 💻 CPU Queries

```promql
# CPU usage percentage (all cores combined)
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# CPU usage per core
100 - (irate(node_cpu_seconds_total{mode="idle"}[5m]) * 100)

# CPU usage by mode (user, system, iowait, etc.)
irate(node_cpu_seconds_total[5m])

# Number of CPU cores
count(node_cpu_seconds_total{mode="idle"})

# CPU iowait (disk bottleneck indicator)
avg(irate(node_cpu_seconds_total{mode="iowait"}[5m])) * 100
```

---

## 🧠 Memory Queries

```promql
# Total memory (GB)
node_memory_MemTotal_bytes / 1024 / 1024 / 1024

# Used memory percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Available memory (GB)
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024

# Swap usage percentage
(1 - (node_memory_SwapFree_bytes / node_memory_SwapTotal_bytes)) * 100

# Memory breakdown
node_memory_Buffers_bytes
node_memory_Cached_bytes
node_memory_MemFree_bytes
```

---

## 💾 Disk Queries

```promql
# Disk usage percentage (per mount point)
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100

# Available disk space (GB)
node_filesystem_avail_bytes{mountpoint="/"} / 1024 / 1024 / 1024

# Disk read/write bytes per second
rate(node_disk_read_bytes_total[5m])
rate(node_disk_written_bytes_total[5m])

# Disk IOPS (I/O operations per second)
rate(node_disk_reads_completed_total[5m])
rate(node_disk_writes_completed_total[5m])

# Predict when disk will be full (linear prediction, 4 hours ahead)
predict_linear(node_filesystem_avail_bytes{mountpoint="/"}[1h], 4*3600) < 0
```

---

## 🌐 Network Queries

```promql
# Network received bytes per second
rate(node_network_receive_bytes_total{device="eth0"}[5m])

# Network transmitted bytes per second
rate(node_network_transmit_bytes_total{device="eth0"}[5m])

# Network errors
rate(node_network_receive_errs_total[5m])
rate(node_network_transmit_errs_total[5m])

# TCP connections by state
node_netstat_Tcp_CurrEstab
node_sockstat_TCP_tw          # TIME_WAIT connections

# Total bandwidth (MB/s)
(rate(node_network_receive_bytes_total[5m]) + rate(node_network_transmit_bytes_total[5m])) / 1024 / 1024
```

---

## 🐳 Container / Kubernetes Queries

```promql
# Container CPU usage
rate(container_cpu_usage_seconds_total{container!="POD", container!=""}[5m])

# Container memory usage
container_memory_usage_bytes{container!="POD", container!=""}

# Container memory limit vs usage
container_memory_usage_bytes / container_spec_memory_limit_bytes * 100

# Container restarts
rate(kube_pod_container_status_restarts_total[15m]) > 0

# Pods not ready
kube_pod_status_ready{condition="false"}

# Pod count by namespace
count by (namespace) (kube_pod_info)

# Deployments with unavailable replicas
kube_deployment_status_replicas_unavailable > 0

# PVC usage percentage
kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes * 100
```

---

## 🚨 Alert-Ready Queries (Common Alert Conditions)

```promql
# High CPU (>80% for 5 min)
100 - (avg by(instance)(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80

# High Memory (>85%)
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85

# Disk almost full (>90%)
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 90

# Target down
up == 0

# High error rate (>5% of requests)
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05

# High latency (p95 > 1 second)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1

# Too many restarts
increase(kube_pod_container_status_restarts_total[1h]) > 5

# Disk will be full in 4 hours
predict_linear(node_filesystem_avail_bytes[1h], 4*3600) < 0

# No replicas available
kube_deployment_status_replicas_available == 0

# Certificate expiry (< 7 days)
(x509_cert_not_after - time()) / 86400 < 7
```

---

## 🔧 Aggregation Operators

```promql
# Sum across all instances
sum(rate(http_requests_total[5m]))

# Sum by specific label
sum by (method) (rate(http_requests_total[5m]))
sum by (endpoint, status) (rate(http_requests_total[5m]))

# Average across instances
avg(node_memory_MemAvailable_bytes)

# Maximum value
max(node_cpu_seconds_total)

# Count number of time series
count(up{job="node-exporter"})

# Top 5 by value
topk(5, rate(http_requests_total[5m]))

# Bottom 5
bottomk(5, node_filesystem_avail_bytes)
```

---

## 🔍 Useful Operators

```promql
# Regex match on labels
http_requests_total{status=~"5.."}          # All 5xx errors
http_requests_total{method=~"GET|POST"}     # GET or POST
http_requests_total{endpoint!~"/health.*"}  # Exclude health endpoints

# Math operations
node_memory_MemTotal_bytes / 1024 / 1024 / 1024    # Convert to GB
rate(http_requests_total[5m]) * 60                  # Per minute instead of per second

# Comparison (returns only matching series)
node_filesystem_avail_bytes < 1073741824            # Less than 1GB free

# Binary operators between metrics
rate(http_requests_total{status="500"}[5m]) / rate(http_requests_total[5m])  # Error ratio

# offset - look at past values
rate(http_requests_total[5m] offset 1h)   # Rate 1 hour ago
rate(http_requests_total[5m]) - rate(http_requests_total[5m] offset 1h)  # Change from 1 hour ago
```

---

## 📊 Common Grafana Dashboard Queries

```promql
# Request Rate (panel title: "Requests/sec")
sum(rate(http_requests_total[5m]))

# Error Rate % (panel title: "Error Rate")
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100

# Latency p95 (panel title: "Response Time")
histogram_quantile(0.95, sum by(le)(rate(http_request_duration_seconds_bucket[5m])))

# CPU Usage (panel title: "CPU %")
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Usage (panel title: "Memory %")
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk Usage (panel title: "Disk %")
(1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100

# Network In/Out (panel title: "Network Bandwidth")
rate(node_network_receive_bytes_total{device="eth0"}[5m]) * 8 / 1024 / 1024  # Mbps in
rate(node_network_transmit_bytes_total{device="eth0"}[5m]) * 8 / 1024 / 1024  # Mbps out
```

---

## 🎯 The 4 Golden Signals (Google SRE)

```promql
# 1. LATENCY — How long requests take
histogram_quantile(0.95, sum by(le)(rate(http_request_duration_seconds_bucket[5m])))

# 2. TRAFFIC — How many requests
sum(rate(http_requests_total[5m]))

# 3. ERRORS — What % of requests fail
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100

# 4. SATURATION — How full is the system
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100   # Memory saturation
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)           # CPU saturation
```

---

## 📖 Reference Links

- [PromQL Documentation](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [PromQL Functions](https://prometheus.io/docs/prometheus/latest/querying/functions/)
- [PromQL Operators](https://prometheus.io/docs/prometheus/latest/querying/operators/)
- [Recording Rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)
- [Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
