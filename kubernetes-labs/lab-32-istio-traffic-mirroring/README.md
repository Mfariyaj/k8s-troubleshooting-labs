## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 32: Istio Traffic Mirroring Not Working

## Difficulty: ⭐⭐⭐⭐

## Scenario

Your team wants to test `user-service` v2 with production traffic without affecting users. The plan is to mirror (shadow) 100% of traffic going to v1 over to v2 for testing. However, v2 pods show no incoming traffic in their access logs — mirroring isn't working.

## Expected Symptoms

- v2 pods receive no mirrored traffic (0 requests in access logs)
- v1 continues to serve all traffic normally
- `istioctl proxy-config routes` shows mirror configuration but it's ineffective
- Possible error references to unknown subsets or hosts

## Your Task

Diagnose why traffic mirroring is broken and fix the configuration.

## Hints

<details>
<summary>Hint 1</summary>
Check the `mirror.host` field. The mirror host must match the actual service name (same service if same service, different subsets). If it references a non-existent service, mirroring silently fails.
</details>

<details>
<summary>Hint 2</summary>
Look at the `mirror.subset` value. If the subset referenced doesn't exist in the DestinationRule, mirrored traffic has nowhere to go.
</details>

<details>
<summary>Hint 3</summary>
Check the `mirrorPercentage.value` type. In Istio's API, this should be a number (float), not a string. A type mismatch may cause the percentage to not apply correctly.
</details>

## Useful Commands

```bash
# Check VirtualService mirror config
kubectl get virtualservice -n lab-32-mirroring -o yaml

# Check DestinationRule subsets
kubectl get destinationrule -n lab-32-mirroring -o yaml

# Check v2 pod logs for mirrored traffic
kubectl logs -n lab-32-mirroring -l version=v2 --tail=20

# Check proxy routes for mirror configuration
istioctl proxy-config routes deploy/traffic-client -n lab-32-mirroring -o json | jq '.[].virtualHosts[].routes[].route.requestMirrorPolicies'

# Generate traffic
kubectl exec deploy/traffic-client -n lab-32-mirroring -- curl -s http://user-service

# Analyze
istioctl analyze -n lab-32-mirroring
```
