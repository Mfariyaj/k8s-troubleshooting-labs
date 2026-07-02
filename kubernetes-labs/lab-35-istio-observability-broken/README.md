## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 35: Istio Observability Stack Broken

## Difficulty: ⭐⭐⭐⭐⭐

## Scenario

Your Istio mesh has a full observability stack (Prometheus, Jaeger, Kiali) but nothing is working:
- Kiali shows an empty service graph — no traffic visualization
- Jaeger has no traces from any service
- Prometheus is not collecting Envoy proxy metrics

The services are running and handling traffic, but the observability tools are blind.

## Expected Symptoms

- Kiali: Empty graph, "No traffic" on all services
- Jaeger: No traces for any service, trace list empty
- Prometheus: Missing `istio_requests_total` and other Envoy metrics
- No access logs from Envoy proxies
- Trace headers not propagated between services

## Your Task

Diagnose the telemetry, tracing, and metrics configuration issues and fix them to restore observability.

## Hints

<details>
<summary>Hint 1</summary>
Check the Istio Telemetry resource. If metrics are disabled or the provider is wrong, Prometheus won't receive any Envoy stats. Also verify that Prometheus scraping is configured correctly (ServiceMonitor or scrape annotations).
</details>

<details>
<summary>Hint 2</summary>
Look at the trace sampling rate. If set to 0 (or 0%), no requests will be traced. The sampling rate should be > 0 for traces to appear in Jaeger (use 100 for testing/debugging, 1 for production).
</details>

<details>
<summary>Hint 3</summary>
Verify `meshConfig.accessLogFile` is set (e.g., `/dev/stdout`). Without it, Envoy won't emit access logs. Also check that the Kiali external_services configuration has correct URLs for Prometheus and Jaeger.
</details>

## Useful Commands

```bash
# Check Telemetry resource
kubectl get telemetry -n lab-35-observability -o yaml
kubectl get telemetry -n istio-system -o yaml

# Check meshConfig
kubectl get configmap istio -n istio-system -o jsonpath='{.data.mesh}' | grep -A5 "accessLog\|tracing"

# Check if envoy emits stats
kubectl exec deploy/web-app -n lab-35-observability -c istio-proxy -- pilot-agent request GET stats | grep istio_requests

# Check proxy access logs
kubectl logs deploy/web-app -n lab-35-observability -c istio-proxy --tail=10

# Check ServiceMonitor
kubectl get servicemonitor -n lab-35-observability -o yaml

# Check Prometheus targets
kubectl port-forward svc/prometheus -n istio-system 9090:9090 &
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job == "envoy-stats")'

# Analyze
istioctl analyze -n lab-35-observability
```
