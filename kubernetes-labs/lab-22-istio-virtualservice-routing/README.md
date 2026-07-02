## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 22: Istio VirtualService Routing Not Working

## Difficulty: ⭐⭐⭐

## Scenario

Your team has deployed two versions of the `reviews` service (v1 and v2) and configured Istio VirtualService routing rules. The expectation is:
- Header-based routing: requests with `end-user: jason` should go to v2
- All other traffic should go to v1
- External traffic via the Istio ingress gateway should also be routed correctly

However, traffic is not being routed correctly — it either goes to the wrong version or returns 404/503 errors.

## Expected Symptoms

- Traffic not splitting correctly between v1 and v2
- External traffic via ingress gateway returns 404
- `istioctl analyze` reports configuration warnings
- Header-based routing not working as expected
- VirtualService appears applied but has no effect

## Your Task

Diagnose the VirtualService and DestinationRule misconfigurations and fix the routing.

## Hints

<details>
<summary>Hint 1</summary>
Compare the `hosts` field in the VirtualService with the actual Kubernetes Service name. They must match exactly.
</details>

<details>
<summary>Hint 2</summary>
Check the subset names referenced in VirtualService routes against the subset names defined in the DestinationRule. They must be identical.
</details>

<details>
<summary>Hint 3</summary>
For external traffic via ingress gateway, the VirtualService must reference the gateway in its `gateways` field. Without this binding, the gateway won't know about the routing rules.
</details>

## Useful Commands

```bash
# Check VirtualService configuration
kubectl get virtualservice -n lab-22-routing -o yaml

# Check DestinationRule subsets
kubectl get destinationrule -n lab-22-routing -o yaml

# Verify service exists
kubectl get svc -n lab-22-routing

# Analyze Istio config for issues
istioctl analyze -n lab-22-routing

# Check proxy configuration
istioctl proxy-config routes deploy/reviews-v1 -n lab-22-routing

# Describe VirtualService
kubectl describe virtualservice reviews-routing -n lab-22-routing
```
