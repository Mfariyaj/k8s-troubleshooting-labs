# Solution: Istio Observability Stack Broken

## Root Cause

Five configuration issues disable observability:

1. **Telemetry resource disables metrics**: The Telemetry resource has `metrics.providers` set to an empty/disabled provider, or metrics are explicitly disabled with `disabled: true`.

2. **Trace sampling set to 0**: With `tracing.randomSamplingPercentage: 0`, zero requests are sampled for tracing. No spans are generated, so Jaeger sees nothing.

3. **Prometheus scrape annotations missing**: The ServiceMonitor or pod annotations for Prometheus scraping are misconfigured. Without proper scrape targets, Prometheus can't collect Envoy metrics.

4. **Kiali `external_services` URLs wrong**: Kiali can't reach Prometheus or Jaeger because the service URLs in its configuration are incorrect, so even if metrics/traces existed, Kiali couldn't display them.

5. **`meshConfig.accessLogFile` empty**: Without setting `accessLogFile: /dev/stdout`, Envoy proxies don't output access logs, making it impossible to debug traffic flow.

## Fix Steps

### Step 1: Fix Telemetry resource

```yaml
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: mesh-telemetry
  namespace: lab-35-observability
spec:
  metrics:
  - providers:
    - name: prometheus
  tracing:
  - providers:
    - name: zipkin
    randomSamplingPercentage: 100
```

### Step 2: Fix ServiceMonitor / Prometheus scrape annotations

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: envoy-stats-monitor
  namespace: lab-35-observability
spec:
  selector:
    matchLabels:
      app: web-app
  endpoints:
  - port: http-envoy-prom
    path: /stats/prometheus
    interval: 15s
  namespaceSelector:
    matchNames:
    - lab-35-observability
```

Or use pod annotations:
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/stats/prometheus"
  prometheus.io/port: "15020"
```

### Step 3: Fix meshConfig (via ConfigMap or IstioOperator)

```yaml
meshConfig:
  accessLogFile: /dev/stdout
  defaultConfig:
    tracing:
      sampling: 100
```

### Step 4: Fix Kiali ConfigMap

```yaml
external_services:
  prometheus:
    url: http://prometheus.istio-system.svc.cluster.local:9090
  tracing:
    url: http://jaeger-query.istio-system.svc.cluster.local:16685
    in_cluster_url: http://jaeger-query.istio-system.svc.cluster.local:16685
```

## Verification

```bash
# Verify Telemetry is configured
kubectl get telemetry -n lab-35-observability -o yaml

# Generate some traffic
kubectl exec deploy/traffic-generator -n lab-35-observability -- sh -c 'for i in $(seq 1 20); do curl -s http://web-app; done'

# Check Envoy stats now include request metrics
kubectl exec deploy/web-app -n lab-35-observability -c istio-proxy -- pilot-agent request GET stats | grep istio_requests_total

# Check access logs appear
kubectl logs deploy/web-app -n lab-35-observability -c istio-proxy --tail=5

# Verify Prometheus is scraping (port-forward first)
kubectl port-forward svc/prometheus -n istio-system 9090:9090 &
curl -s "http://localhost:9090/api/v1/query?query=istio_requests_total" | jq '.data.result | length'

# Check Jaeger for traces
kubectl port-forward svc/jaeger-query -n istio-system 16686:16686 &
curl -s "http://localhost:16686/api/traces?service=web-app.lab-35-observability" | jq '.data | length'
```
