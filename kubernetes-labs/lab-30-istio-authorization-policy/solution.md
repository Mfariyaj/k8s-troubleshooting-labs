# Solution: Istio Authorization Policy Blocking Traffic

## Root Cause

Four issues with the authorization policies:

1. **DENY policy `to: [{}]` matches everything**: The namespace-level DENY policy has an empty `to` block (`- {}`), which means it matches ALL requests to ALL paths. Combined with `from.source.principals: ["unknown-sa"]`, this DENY applies more broadly than intended.

2. **Wrong principal format in DENY policy**: `principals: ["unknown-sa"]` should use SPIFFE format `cluster.local/ns/<namespace>/sa/<sa-name>`. Without proper format, matching behavior is unpredictable.

3. **ALLOW policy selector mismatch**: The ALLOW policy targets `app: backend` but the actual pods have label `app: backend-api`. The policy isn't applied to the correct workload.

4. **ALLOW policy wrong principal format**: `principals: ["frontend-sa"]` should be `cluster.local/ns/lab-30-authz/sa/frontend-sa`. Without the full SPIFFE identity, the source won't match.

## Fix Steps

### Corrected Authorization Policies

```yaml
# Remove or fix the namespace-level DENY policy
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: deny-all-default
  namespace: lab-30-authz
spec:
  # Apply only to workloads that need default-deny
  action: DENY
  rules:
  - from:
    - source:
        notPrincipals:
          - "cluster.local/ns/lab-30-authz/sa/frontend-sa"
          - "cluster.local/ns/lab-30-authz/sa/admin-sa"
---
# Alternatively, use a simpler default-deny and explicit ALLOWs:
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: lab-30-authz
spec:
  selector:
    matchLabels:
      # Fixed: matches actual pod label
      app: backend-api
  action: ALLOW
  rules:
  - from:
    - source:
        # Fixed: full SPIFFE identity format
        principals: ["cluster.local/ns/lab-30-authz/sa/frontend-sa"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/*"]
  - from:
    - source:
        principals: ["cluster.local/ns/lab-30-authz/sa/admin-sa"]
```

### Recommended Pattern

The cleanest approach is:
1. Delete the broad DENY policy
2. Create a namespace-level default-deny (empty AuthorizationPolicy with no rules)
3. Add specific ALLOW policies per workload

```yaml
# Default deny all in namespace
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: default-deny
  namespace: lab-30-authz
spec:
  {}
---
# Explicit allow for frontend -> backend
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: lab-30-authz
spec:
  selector:
    matchLabels:
      app: backend-api
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/lab-30-authz/sa/frontend-sa"]
    to:
    - operation:
        methods: ["GET", "POST"]
```

## Verification

```bash
# Apply fixes
kubectl apply -f corrected-authz.yaml

# Test frontend -> backend (should work)
kubectl exec deploy/frontend -n lab-30-authz -- curl -s -o /dev/null -w "%{http_code}" http://backend-api

# Test unauthorized access (should be denied)
kubectl exec deploy/admin-service -n lab-30-authz -- curl -s -o /dev/null -w "%{http_code}" http://backend-api

# Check RBAC stats
kubectl exec deploy/backend-api -n lab-30-authz -c istio-proxy -- pilot-agent request GET stats | grep rbac

# Analyze
istioctl analyze -n lab-30-authz
```
