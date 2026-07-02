## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 24: Istio Blue-Green Deployment Broken

## Difficulty: ⭐⭐⭐⭐

## Scenario

Your team is performing a blue-green deployment for the `frontend` service. The green version (v2) has been deployed and tested, and it's time to switch all traffic from blue to green. However, after updating the configuration, the old blue pods still receive traffic and the green pods aren't getting any requests.

## Expected Symptoms

- Blue pods still receiving traffic after the "switch"
- Green pods show 0 requests in metrics
- `istioctl proxy-config` shows routing to blue subset only
- VirtualService appears updated but traffic flow unchanged
- Possible 503 errors when trying to route to green subset

## Your Task

Diagnose why the blue-green switch isn't completing and fix all configuration issues to route 100% traffic to green.

## Hints

<details>
<summary>Hint 1</summary>
Check which subset the VirtualService is currently pointing to. Has it actually been switched to 'green'?
</details>

<details>
<summary>Hint 2</summary>
Compare the DestinationRule's green subset label selector with the actual labels on the green pods. Even a typo (colour vs color) will cause a mismatch.
</details>

<details>
<summary>Hint 3</summary>
Look at the Service selector. If it matches both blue and green pods without using Istio subsets properly, Kubernetes-level load balancing may interfere with Istio routing.
</details>

## Useful Commands

```bash
# Check pod labels
kubectl get pods -n lab-24-bluegreen --show-labels

# Check VirtualService routing
kubectl get virtualservice -n lab-24-bluegreen -o yaml

# Check DestinationRule subsets vs pod labels
kubectl get destinationrule -n lab-24-bluegreen -o yaml

# Analyze configuration
istioctl analyze -n lab-24-bluegreen

# Check endpoints behind the service
kubectl get endpoints frontend -n lab-24-bluegreen

# Proxy config
istioctl proxy-config clusters deploy/frontend-green -n lab-24-bluegreen | grep frontend
```
