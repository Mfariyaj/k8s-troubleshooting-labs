## Solution: ImagePullBackOff

### Root Cause

The deployment uses the image `nginx:trixie-perl` which is a non-existent or invalid tag. Kubernetes cannot pull this image from the registry, causing ImagePullBackOff.

### Diagnosis

```bash
kubectl get pods -n lab-02
kubectl describe pod -n lab-02 -l app=api-service
kubectl get events -n lab-02 --sort-by='.lastTimestamp'
```

Events will show: `Failed to pull image "nginx:trixie-perl": ... not found`

### Fix

Change the image to a valid nginx tag:

```bash
kubectl set image deployment/api-service api=nginx:1.25 -n lab-02
```

Or edit the deployment:

```bash
kubectl edit deployment api-service -n lab-02
```

Change `image: nginx:trixie-perl` to `image: nginx:1.25`

### Fixed YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  namespace: lab-02
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
      - name: api
        image: nginx:1.25
        ports:
        - containerPort: 80
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
kubectl get pods -n lab-02
# All 3 pods should be Running
kubectl describe pod -n lab-02 -l app=api-service | grep "Image:"
# Should show nginx:1.25
```
