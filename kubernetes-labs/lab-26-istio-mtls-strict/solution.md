# Solution: Istio mTLS Strict Mode Breaking Communication

## Root Cause

Two issues cause the communication breakdown:

1. **Database pod has sidecar injection disabled**: The database deployment has `sidecar.istio.io/inject: "false"` annotation. Without a sidecar, it cannot participate in mTLS. When PeerAuthentication is STRICT, the database cannot receive mTLS connections because it has no Envoy proxy to terminate them.

2. **DestinationRule TLS mode conflicts**: The DestinationRule for the database has `tls.mode: DISABLE`, which tells the client's sidecar NOT to use mTLS. But if we fix the database to have a sidecar with STRICT PeerAuthentication, the client would need to use ISTIO_MUTUAL. This creates a circular conflict.

## Fix Steps

### Option A: Enable sidecar on database (recommended)

Remove the `sidecar.istio.io/inject: "false"` annotation and change DestinationRule to ISTIO_MUTUAL.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  namespace: lab-26-mtls
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
      # Remove the inject: false annotation
    spec:
      containers:
      - name: database
        image: mysql:8.0
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpass"
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: database-dr
  namespace: lab-26-mtls
spec:
  host: database
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
```

### Option B: Add workload-specific PeerAuthentication exception

If the database truly cannot have a sidecar, create a port-level exception:

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: database-exception
  namespace: lab-26-mtls
spec:
  selector:
    matchLabels:
      app: database
  mtls:
    mode: DISABLE
  portLevelMtls:
    3306:
      mode: DISABLE
```

## Verification

```bash
# After fix, verify all pods have sidecars
kubectl get pods -n lab-26-mtls

# Check mTLS status
istioctl authn tls-check deploy/api-backend -n lab-26-mtls

# Test connectivity
kubectl exec deploy/api-backend -n lab-26-mtls -- curl -s database:3306

# Verify no conflicts
istioctl analyze -n lab-26-mtls
```
