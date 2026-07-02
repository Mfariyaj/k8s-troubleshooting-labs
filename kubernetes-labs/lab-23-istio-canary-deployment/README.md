## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 23: Istio Canary Deployment Broken

## Difficulty: ⭐⭐⭐⭐

## Scenario

Your team is rolling out a canary deployment of the `product-api` service. The plan is to send 90% of traffic to v1 (stable) and 10% to v2 (canary). However, after deploying the Istio configuration, the traffic split isn't working correctly — all traffic goes to v1, and v2 never receives any requests.

## Expected Symptoms

- Traffic never reaches `product-api-v2` pods
- VirtualService appears configured but weight split has no effect
- `istioctl analyze` may report errors about subsets or weight configuration
- Proxy config shows routing issues
- 503 errors when Istio tries to route to undefined subset

## Your Task

Diagnose why the canary deployment traffic split is failing and fix the configuration to achieve a proper 90/10 split.

## Hints

<details>
<summary>Hint 1</summary>
Check if the weights in the VirtualService route destinations sum to exactly 100. Istio requires weights to total 100%.
</details>

<details>
<summary>Hint 2</summary>
Examine the DestinationRule subsets. Are all subsets referenced in the VirtualService actually defined? A missing subset definition will cause 503 errors.
</details>

<details>
<summary>Hint 3</summary>
Compare the label selectors in the DestinationRule subsets with the actual labels on the v2 pods. The labels must match for Istio to identify which pods belong to which subset.
</details>

## Useful Commands

```bash
# Check running pods and their labels
kubectl get pods -n lab-23-canary --show-labels

# Check VirtualService config
kubectl get virtualservice -n lab-23-canary -o yaml

# Check DestinationRule subsets
kubectl get destinationrule -n lab-23-canary -o yaml

# Analyze configuration
istioctl analyze -n lab-23-canary

# Check proxy routes
istioctl proxy-config routes deploy/product-api-v1 -n lab-23-canary

# Check clusters
istioctl proxy-config clusters deploy/product-api-v1 -n lab-23-canary | grep product-api
```
