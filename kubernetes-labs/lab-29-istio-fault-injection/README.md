# Lab 29: Istio Fault Injection Not Working

## Difficulty: ⭐⭐⭐

## Scenario

Your team is using Istio fault injection for chaos testing the `catalog-service`. The goal is to inject a 5-second delay and 50% abort (HTTP 500) for test traffic only (identified by header `x-test-user: chaos-tester`). However:
- Faults are not being injected at all for test traffic
- OR faults are applied to ALL traffic (including production)

## Expected Symptoms

- Test requests with proper headers don't experience injected delays or aborts
- Production traffic experiencing unexpected 500 errors and delays
- Fault injection percentage appears invalid
- `istioctl analyze` may not catch all issues with fault injection values

## Your Task

Fix the fault injection configuration to properly inject faults only for test traffic.

## Hints

<details>
<summary>Hint 1</summary>
Check the fault abort percentage value. In Istio, the percentage must be between 0 and 100 (as a float value). A value > 100 is invalid and may cause the fault to not apply.
</details>

<details>
<summary>Hint 2</summary>
Look at the fault delay `fixedDelay` format. Istio requires duration format with units (e.g., '5s' for 5 seconds). Just '5' without a unit suffix is invalid.
</details>

<details>
<summary>Hint 3</summary>
Check if the match conditions (headers) in the VirtualService actually match what the test client sends. Also verify that the fault is applied only to the matched route, not to a catch-all route below it.
</details>

## Useful Commands

```bash
# Check VirtualService fault config
kubectl get virtualservice -n lab-29-fault-injection -o yaml

# Test with headers
kubectl exec deploy/catalog-client -n lab-29-fault-injection -- curl -H "x-test-user: chaos-tester" http://catalog-service

# Check proxy config
istioctl proxy-config routes deploy/catalog-client -n lab-29-fault-injection -o json

# Analyze
istioctl analyze -n lab-29-fault-injection

# Check Envoy fault injection stats
kubectl exec deploy/catalog-client -n lab-29-fault-injection -c istio-proxy -- pilot-agent request GET stats | grep fault
```
