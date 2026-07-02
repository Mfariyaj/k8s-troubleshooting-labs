## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4845

## Priority: P3 - Medium | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] HPA not scaling - shows "unknown" metrics, stuck at minimum replicas

### Reporter: Sneha Patil (Performance Engineering)
### Created: 2026-07-01 12:15 IST
### Environment: Production (lab-13 namespace)

---

### Description:

We configured a HorizontalPodAutoscaler for `scalable-app` but it's not scaling. The HPA shows `<unknown>` for current CPU/memory utilization and a custom metric `http_requests_per_second` that doesn't exist.

The minReplicas is 2, but we sometimes see only 1 pod running (HPA can't enforce minimum because it can't read metrics).

---

### What we know:
- HPA `scalable-app-hpa` exists in namespace
- It targets deployment `scalable-app`
- minReplicas: 2, maxReplicas: 10
- HPA shows `<unknown>/50%` for CPU utilization
- HPA references a custom metric `http_requests_per_second` (no custom metrics adapter installed)
- `kubectl top pods` might not work (metrics-server possibly missing/broken)
- Deployment currently has 1-2 pods running

---

### Observations from on-call:
```
$ kubectl get hpa -n lab-13
NAME               REFERENCE                 TARGETS          MINPODS   MAXPODS   REPLICAS
scalable-app-hpa   Deployment/scalable-app   <unknown>/50%    2         10        2

$ kubectl describe hpa -n lab-13 scalable-app-hpa
Conditions:
  Type            Status  Reason
  AbleToScale     True    SucceededGetScale
  ScalingActive   False   FailedGetResourceMetric
  
Events:
  Warning  FailedGetResourceMetric  failed to get cpu utilization: 
    unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedGetExternalMetric  unable to fetch metrics from custom metrics API:
    the server could not find the requested resource (get pods.custom.metrics.k8s.io)
```

---

### Action Required:
1. Check if metrics-server is installed and running (`kubectl get deployment metrics-server -n kube-system`)
2. If missing, install metrics-server
3. Remove the custom metric `http_requests_per_second` from HPA (no adapter available)
4. Verify `kubectl top pods` works after fix
5. Confirm HPA shows actual CPU percentage and scales properly

---

### Note:
- Docker Desktop should have metrics-server but it might be disabled
- The custom metric was a "nice to have" — remove it for now, keep only CPU-based scaling

### SLA: 4 hours (P3 scaling optimization)
