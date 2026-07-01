## Solution: CrashLoopBackOff

### Root Cause

The container command has a typo: `ngInx` instead of `nginx`. The shell cannot find the binary, causing the container to exit immediately and enter CrashLoopBackOff.

### Diagnosis

```bash
kubectl get pods -n lab-01
kubectl describe pod -n lab-01 -l app=web-app
kubectl logs -n lab-01 -l app=web-app
```

The logs will show: `/bin/sh: ngInx: not found`

### Fix

Edit the deployment to fix the command:

```bash
kubectl edit deployment web-app -n lab-01
```

Change the command from:
```yaml
command: ["/bin/sh", "-c", "ngInx -g 'daemon off;'"]
```

To:
```yaml
command: ["/bin/sh", "-c", "nginx -g 'daemon off;'"]
```

### Fixed YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: lab-01
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
        command: ["/bin/sh", "-c", "nginx -g 'daemon off;'"]
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
kubectl get pods -n lab-01
# All pods should be Running
kubectl logs -n lab-01 -l app=web-app
# No errors, nginx serving normally
```
