# Solution: Istio Traffic Mirroring Not Working

## Root Cause

Three issues with the mirroring configuration:

1. **`mirror.host` references non-existent service**: The mirror host is `user-svc-v2` but the actual service is `user-service`. Mirror traffic can't be sent to a non-existent host.

2. **`mirror.subset` references undefined subset**: The mirror uses `subset: canary`, but the DestinationRule only defines `v1` and `v2` subsets. There's no `canary` subset.

3. **`mirrorPercentage.value` is a string**: The value is `"100"` (string) instead of `100.0` (number). While some versions may handle this, it's technically incorrect and can cause issues.

## Fix Steps

### Corrected VirtualService

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: user-service-mirror
  namespace: lab-32-mirroring
spec:
  hosts:
  - user-service
  http:
  - route:
    - destination:
        host: user-service
        subset: v1
      weight: 100
    mirror:
      host: user-service
      subset: v2
    mirrorPercentage:
      value: 100.0
```

### Key Fixes:
1. Changed `host: user-svc-v2` → `host: user-service` (correct service name)
2. Changed `subset: canary` → `subset: v2` (matches DestinationRule)
3. Changed `value: "100"` → `value: 100.0` (numeric type)

## Verification

```bash
# Apply fix
kubectl apply -f corrected-virtualservice.yaml

# Generate traffic
kubectl exec deploy/traffic-client -n lab-32-mirroring -- sh -c 'for i in $(seq 1 10); do curl -s http://user-service; done'

# Check v2 access logs for mirrored traffic
kubectl logs -n lab-32-mirroring -l version=v2 --tail=20

# Note: Mirrored requests have "-shadow" appended to the Host header
kubectl logs -n lab-32-mirroring -l version=v2 | grep "shadow"

# Verify proxy config
istioctl proxy-config routes deploy/traffic-client -n lab-32-mirroring -o json | jq '.[].virtualHosts[].routes[].route.requestMirrorPolicies'

# Analyze
istioctl analyze -n lab-32-mirroring
```
