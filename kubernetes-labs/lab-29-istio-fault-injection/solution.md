# Solution: Istio Fault Injection Not Working

## Root Cause

Four issues with the fault injection configuration:

1. **`fixedDelay: "5"` missing time unit**: Istio requires duration format with units like `5s` (seconds), `100ms` (milliseconds), or `1m` (minutes). Just `"5"` is invalid.

2. **Abort percentage > 100**: The abort percentage is `150.0`, which exceeds the valid range of 0-100. This makes the fault injection invalid.

3. **Fault applied to catch-all route**: The fault block is on the first route without a match condition, meaning it applies to ALL traffic — not just test traffic. It should be on the matched route.

4. **Header name mismatch**: The match condition checks for `x-chaos-test: "true"`, but test clients send `x-test-user: chaos-tester`. The header name and value don't match.

## Fix Steps

### Corrected VirtualService

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: catalog-fault-injection
  namespace: lab-29-fault-injection
spec:
  hosts:
  - catalog-service
  http:
  # Test traffic route WITH fault injection (matched first)
  - match:
    - headers:
        x-test-user:
          exact: "chaos-tester"
    fault:
      delay:
        fixedDelay: 5s
        percentage:
          value: 50.0
      abort:
        httpStatus: 500
        percentage:
          value: 50.0
    route:
    - destination:
        host: catalog-service
  # Normal traffic route WITHOUT faults (catch-all, last)
  - route:
    - destination:
        host: catalog-service
```

### Key Fixes:
1. Changed `fixedDelay: "5"` → `fixedDelay: 5s`
2. Changed abort `percentage.value: 150.0` → `50.0`
3. Moved fault to the matched route (test traffic only)
4. Fixed header from `x-chaos-test: "true"` to `x-test-user: "chaos-tester"`
5. Moved the match route BEFORE the catch-all route

## Verification

```bash
# Apply fix
kubectl apply -f corrected-virtualservice.yaml

# Test: Normal traffic should NOT be affected
kubectl exec deploy/catalog-client -n lab-29-fault-injection -- curl -s -o /dev/null -w "%{http_code} %{time_total}\n" http://catalog-service

# Test: Traffic with test header should see delays/aborts
kubectl exec deploy/catalog-client -n lab-29-fault-injection -- curl -s -o /dev/null -w "%{http_code} %{time_total}\n" -H "x-test-user: chaos-tester" http://catalog-service

# Run multiple requests to see fault percentage
for i in $(seq 1 20); do
  kubectl exec deploy/catalog-client -n lab-29-fault-injection -- curl -s -o /dev/null -w "%{http_code}\n" -H "x-test-user: chaos-tester" http://catalog-service
done
```
