## Solution: Health Degraded — Invalid Image Tag

### Root Cause
The Deployment uses `image: nginx:nonexistent` which does not exist in the container registry. Pods enter `ImagePullBackOff`, causing the Deployment to report `Degraded` health in ArgoCD.

### Step-by-Step Fix

1. Check the application health:
   ```bash
   argocd app get health-degraded-app
   ```
2. Inspect pod events:
   ```bash
   kubectl describe pods -n health-degraded-lab | grep -A5 "Events"
   ```
3. Fix the Deployment image tag to a valid version:
   ```bash
   kubectl set image deployment/nginx-app nginx=nginx:1.25 -n health-degraded-lab
   ```

### Fixed YAML
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  namespace: health-degraded-lab
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10
```

### Verification
```bash
argocd app get health-degraded-app
# Health: Healthy
kubectl get pods -n health-degraded-lab
# All pods Running and Ready
argocd app wait health-degraded-app --health --timeout 120
```
