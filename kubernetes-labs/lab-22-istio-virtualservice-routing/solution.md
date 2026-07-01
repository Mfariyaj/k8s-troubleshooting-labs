# Solution: Istio VirtualService Routing Not Working

## Root Cause

Three issues prevent correct routing:

1. **VirtualService host mismatch**: The VirtualService uses `reviews-svc` as the host, but the actual Kubernetes Service is named `reviews`. Istio can't match the VirtualService to any real service.

2. **Subset name mismatch**: The VirtualService references subset `version-1`, but the DestinationRule defines the subset as `v1`. The names must match exactly.

3. **Missing gateway binding**: The VirtualService doesn't reference the `reviews-gateway` in its `gateways` field, so external traffic through the ingress gateway has no routing rules applied.

## Fix Steps

### Step 1: Fix the host name in VirtualService

Change `reviews-svc` to `reviews` (matching the Kubernetes Service name).

### Step 2: Fix the subset name

Change `version-1` to `v1` (matching the DestinationRule subset name).

### Step 3: Add gateway reference

Add `gateways: ["reviews-gateway", "mesh"]` to route both external and internal traffic.

### Corrected VirtualService

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: reviews-routing
  namespace: lab-22-routing
spec:
  hosts:
  - reviews
  gateways:
  - reviews-gateway
  - mesh
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
```

## Verification

```bash
# Apply fixes
kubectl apply -f corrected-virtualservice.yaml

# Verify with istioctl analyze (should show no errors)
istioctl analyze -n lab-22-routing

# Test internal routing
kubectl exec -n lab-22-routing deploy/reviews-v1 -c reviews -- curl -s -H "end-user: jason" http://reviews

# Check routes are configured in proxy
istioctl proxy-config routes deploy/reviews-v1 -n lab-22-routing
```
