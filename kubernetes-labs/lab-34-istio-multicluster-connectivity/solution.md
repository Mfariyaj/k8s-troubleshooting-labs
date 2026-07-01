# Solution: Istio Multi-Cluster Connectivity Broken

## Root Cause

Four issues break cross-cluster connectivity:

1. **ServiceEntry endpoint port wrong (80 vs 15443)**: In Istio multi-cluster with gateway-based connectivity, cross-cluster traffic is routed through the ingress gateway on port 15443 (SNI-based auto-mTLS). The endpoint should use port 15443, not 80.

2. **DestinationRule TLS mode DISABLE**: Cross-cluster communication requires mTLS between clusters. Setting `mode: DISABLE` means the local proxy sends plaintext to the remote gateway, which expects mTLS.

3. **Gateway port wrong (80 vs 15443)**: The cross-cluster gateway should listen on port 15443 with AUTO_PASSTHROUGH TLS mode for SNI-based routing.

4. **Trust domain mismatch (implicit)**: If clusters use different trust domains (e.g., `cluster-a.local` vs `cluster-b.local`), certificates won't validate. Both clusters need a shared root CA or trust domain aliases configured.

## Fix Steps

### Corrected ServiceEntry

```yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: remote-backend-cluster-b
  namespace: lab-34-multicluster
spec:
  hosts:
  - backend.production.svc.cluster.local
  location: MESH_INTERNAL
  ports:
  - number: 80
    name: http
    protocol: HTTP
  resolution: STATIC
  endpoints:
  - address: 10.10.10.1
    ports:
      http: 15443
    labels:
      cluster: cluster-b
    network: network-b
```

### Corrected DestinationRule

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: remote-backend-dr
  namespace: lab-34-multicluster
spec:
  host: backend.production.svc.cluster.local
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
```

### Corrected Gateway

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: cross-cluster-gateway
  namespace: lab-34-multicluster
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 15443
      name: tls
      protocol: TLS
    tls:
      mode: AUTO_PASSTHROUGH
    hosts:
    - "*.local"
```

### Trust Domain Configuration

Ensure both clusters share the same root CA or configure trust domain aliases in the mesh config:
```yaml
meshConfig:
  trustDomainAliases:
  - cluster-a.local
  - cluster-b.local
```

## Verification

```bash
# Apply fixes
kubectl apply -f corrected-multicluster.yaml

# Verify endpoint port
istioctl proxy-config endpoints deploy/local-frontend -n lab-34-multicluster | grep backend

# Verify TLS mode
istioctl proxy-config clusters deploy/local-frontend -n lab-34-multicluster -o json | jq '.[] | select(.name | contains("backend"))'

# Test connectivity (will timeout if remote cluster not actually available)
kubectl exec deploy/local-frontend -n lab-34-multicluster -- curl -s http://backend.production.svc.cluster.local

# Analyze
istioctl analyze -n lab-34-multicluster
```
