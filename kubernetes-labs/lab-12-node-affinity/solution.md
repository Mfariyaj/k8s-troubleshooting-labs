## Solution: Node Affinity Mismatch

### Root Cause

The pod has a `requiredDuringSchedulingIgnoredDuringExecution` node affinity requiring nodes with labels `accelerator/gpu: nvidia-tesla-v100` (or `nvidia-a100`) AND `node-type: high-memory`. No nodes in the cluster have these labels, so the pod remains Pending.

### Diagnosis

```bash
kubectl get pods -n lab-12
kubectl describe pod -n lab-12 -l app=gpu-workload
kubectl get nodes --show-labels
```

Events: `0/X nodes are available: X node(s) didn't match Pod's node affinity/selector`

### Fix

Option 1: Label an existing node to match the affinity rules:

```bash
kubectl label nodes <node-name> accelerator/gpu=nvidia-tesla-v100
kubectl label nodes <node-name> node-type=high-memory
```

Option 2: Remove/relax the affinity constraints:

```bash
kubectl edit deployment gpu-workload -n lab-12
```

### Fixed YAML (removing strict affinity)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpu-workload
  namespace: lab-12
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gpu-workload
  template:
    metadata:
      labels:
        app: gpu-workload
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: accelerator/gpu
                operator: In
                values:
                - nvidia-tesla-v100
                - nvidia-a100
      containers:
      - name: gpu-app
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
kubectl get pods -n lab-12
# Pod should be Running
kubectl describe pod -n lab-12 -l app=gpu-workload | grep "Node:"
# Should show assigned node
```
