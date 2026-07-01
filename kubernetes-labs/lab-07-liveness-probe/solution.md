## Solution: Liveness Probe Failure

### Root Cause

The liveness and readiness probes target port `8080` with paths `/healthz` and `/ready`, but the nginx container only listens on port `80` and doesn't have those custom endpoints. The probes fail repeatedly, causing Kubernetes to kill and restart the container.

### Diagnosis

```bash
kubectl get pods -n lab-07
kubectl describe pod -n lab-07 -l app=health-app
kubectl logs -n lab-07 -l app=health-app --previous
```

Events will show: `Liveness probe failed: connection refused` (port 8080 is not open)

### Fix

Change the probe port to `80` and path to `/` (nginx default):

```bash
kubectl edit deployment health-app -n lab-07
```

### Fixed YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: health-app
  namespace: lab-07
spec:
  replicas: 2
  selector:
    matchLabels:
      app: health-app
  template:
    metadata:
      labels:
        app: health-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 5
          failureThreshold: 2
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 5
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
kubectl get pods -n lab-07
# Pods should be Running with READY 1/1
kubectl describe pod -n lab-07 -l app=health-app | grep -A3 "Liveness:"
# Probes should target port 80
```
