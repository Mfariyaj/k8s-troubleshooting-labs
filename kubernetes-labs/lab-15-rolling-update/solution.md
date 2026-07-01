## Solution: Rolling Update Stuck

### Root Cause

The readiness probe targets port `9090` with path `/api/v2/health`, but nginx only listens on port `80`. New pods never pass the readiness check, so the rolling update stalls (maxUnavailable: 0 means old pods can't be terminated until new pods are ready).

### Diagnosis

```bash
kubectl get pods -n lab-15
kubectl rollout status deployment payment-service -n lab-15
kubectl describe pod -n lab-15 -l app=payment-service
kubectl get events -n lab-15 --sort-by='.lastTimestamp'
```

Events show: `Readiness probe failed: connection refused` on port 9090.

### Fix

Change probe port to `80` and path to `/`:

```bash
kubectl edit deployment payment-service -n lab-15
```

### Fixed YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
  namespace: lab-15
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
        version: v2
    spec:
      containers:
      - name: app
        image: nginx:1.25
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 3
          failureThreshold: 3
          successThreshold: 1
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 10
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
```

### Verification

```bash
kubectl rollout status deployment payment-service -n lab-15
# Should show "successfully rolled out"
kubectl get pods -n lab-15
# All 3 pods Running and Ready 1/1
```
