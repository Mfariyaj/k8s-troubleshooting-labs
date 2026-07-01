## Solution: Pod Disruption Budget Too Restrictive

### Root Cause

Two overly restrictive PodDisruptionBudgets block all voluntary evictions:
1. `order-processor-pdb`: `minAvailable: 3` with 3 replicas — no pod can ever be evicted.
2. `inventory-service-pdb`: `maxUnavailable: 0` — completely blocks any eviction.

This prevents node drains, cluster upgrades, and voluntary disruptions.

### Diagnosis

```bash
kubectl get pdb -n lab-17-pdb
kubectl describe pdb -n lab-17-pdb
# Try a drain to confirm it blocks:
kubectl drain <node-name> --dry-run=client
```

PDB status shows `ALLOWED DISRUPTIONS: 0` for both.

### Fix

Adjust PDBs to allow at least one pod disruption:

```bash
kubectl apply -f - <<EOF
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: order-processor-pdb
  namespace: lab-17-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: order-processor
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: inventory-service-pdb
  namespace: lab-17-pdb
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: inventory-service
EOF
```

### Fixed YAML

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: order-processor-pdb
  namespace: lab-17-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: order-processor
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: inventory-service-pdb
  namespace: lab-17-pdb
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: inventory-service
```

### Verification

```bash
kubectl get pdb -n lab-17-pdb
# ALLOWED DISRUPTIONS should be >= 1 for both
kubectl describe pdb order-processor-pdb -n lab-17-pdb | grep "Allowed disruptions"
kubectl describe pdb inventory-service-pdb -n lab-17-pdb | grep "Allowed disruptions"
```
