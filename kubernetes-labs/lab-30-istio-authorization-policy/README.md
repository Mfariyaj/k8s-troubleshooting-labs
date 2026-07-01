# Lab 30: Istio Authorization Policy Blocking Traffic

## Difficulty: ⭐⭐⭐⭐⭐

## Scenario

Your team implemented Istio AuthorizationPolicy to secure service-to-service communication in the `lab-30-authz` namespace. The intent is:
- Only `frontend` can talk to `backend-api`
- External requests to `backend-api` should be denied
- Admin service has unrestricted access

However, even legitimate traffic from `frontend` to `backend-api` is being blocked with RBAC access denied errors.

## Expected Symptoms

- `RBAC: access denied` responses when frontend calls backend
- HTTP 403 Forbidden from services that should be allowed
- All traffic blocked, not just unauthorized traffic
- Admin service also denied despite intended unrestricted access

## Your Task

Diagnose the AuthorizationPolicy misconfigurations and fix them to properly allow legitimate traffic.

## Hints

<details>
<summary>Hint 1</summary>
Check the `from.source.principals` format. Istio identity uses SPIFFE format: `cluster.local/ns/<namespace>/sa/<service-account>`. Missing the `spiffe://` prefix or using wrong format prevents matching.
</details>

<details>
<summary>Hint 2</summary>
Look at the ALLOW policy's `selector.matchLabels`. If it doesn't match the target workload's actual labels, the policy won't be applied to the right pods.
</details>

<details>
<summary>Hint 3</summary>
An AuthorizationPolicy with empty `rules.to` field (or empty operations) matches nothing, effectively blocking everything. Also check if a namespace-level DENY policy is overriding workload-level ALLOW policies.
</details>

## Useful Commands

```bash
# Check all authorization policies
kubectl get authorizationpolicy -n lab-30-authz -o yaml

# Test connectivity
kubectl exec deploy/frontend -n lab-30-authz -- curl -s -o /dev/null -w "%{http_code}" http://backend-api

# Check Envoy RBAC stats
kubectl exec deploy/backend-api -n lab-30-authz -c istio-proxy -- pilot-agent request GET stats | grep rbac

# Check service account identity
kubectl get pods -n lab-30-authz -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.serviceAccountName}{"\n"}{end}'

# Analyze
istioctl analyze -n lab-30-authz
```
