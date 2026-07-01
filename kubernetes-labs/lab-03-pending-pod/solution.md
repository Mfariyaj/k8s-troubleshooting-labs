## Solution: Pending Pod

### Root Cause

The pod requests `128Gi` memory and `64` CPU cores, which exceeds any node's available capacity. The scheduler cannot find a node to place the pod, so it remains in Pending state.

### Diagnosis

```bash
kubectl get pods -n lab-03
kubectl describe pod -n lab-03 -l app=resource-hungry-app
kubectl get nodes -o custom-columns=NAME:.metadata.name,MEM:.status.allocatable.memory,CPU:.status.allocatable.cpu
```

Events will show: `0/X nodes are available: X Insufficient memory, X Insufficient cpu`

### Fix

Reduce resource requests to reasonable values:

```bash
kubectl edit deployment resource-hungry-app -n lab-03
```

Change memory from `128Gi`/`256Gi` to `128Mi`/`256Mi` and CPU from `64`/`128` to `100m`/`200m`.

### Fixed YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-hungry-app
  namespace: lab-03
spec:
  replicas: 1
  selector:
    matchLabels:
      app: resource-hungry-app
  template:
    metadata:
      labels:
        app: resource-hungry-app
    spec:
      containers:
      - name: app
        image: nginx:1.25
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

### Verification

```bash
kubectl get pods -n lab-03
# Pod should transition from Pending to Running
kubectl describe pod -n lab-03 -l app=resource-hungry-app | grep -A2 "Requests:"
# Should show reasonable resource values
```
