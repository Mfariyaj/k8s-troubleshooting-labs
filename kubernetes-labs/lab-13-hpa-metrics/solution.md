## Solution: HPA Metrics Issue

### Root Cause

The HPA references a custom metric `http_requests_per_second` (type: Pods) that doesn't exist. Additionally, if metrics-server is not installed, the CPU/memory metrics also fail. The HPA shows `<unknown>` for current metrics and cannot scale.

### Diagnosis

```bash
kubectl get hpa -n lab-13
kubectl describe hpa scalable-app-hpa -n lab-13
kubectl top pods -n lab-13
kubectl get apiservice | grep metrics
```

HPA will show: `unable to get metric http_requests_per_second` and possibly `unable to fetch metrics from resource metrics API`

### Fix

1. Install metrics-server (if not present):

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# For local clusters (minikube/kind), add --kubelet-insecure-tls flag
```

2. Remove the custom metric that doesn't exist:

```bash
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: scalable-app-hpa
  namespace: lab-13
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scalable-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
EOF
```

### Verification

```bash
kubectl get hpa -n lab-13
# TARGETS should show actual percentages, not <unknown>
kubectl get pods -n lab-13
# Should show at least 2 pods (minReplicas)
kubectl top pods -n lab-13
# Should show CPU/memory usage
```
