## Solution: NetworkPolicy Blocking Traffic

### Root Cause

Two NetworkPolicy issues prevent frontend-to-backend communication:
1. A `deny-all-ingress` policy blocks ALL ingress and egress traffic for all pods.
2. The only allow policy (`allow-backend-from-monitoring`) permits ingress only from pods with label `role: monitoring`, not from the frontend which has `role: frontend`.

### Diagnosis

```bash
kubectl get networkpolicy -n lab-09
kubectl describe networkpolicy -n lab-09
kubectl get pods -n lab-09 --show-labels
kubectl exec -n lab-09 -l app=frontend-client -- curl -s --connect-timeout 3 http://backend-svc
```

### Fix

Add policies to allow frontend-to-backend traffic and DNS egress:

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: lab-09
spec:
  podSelector:
    matchLabels:
      app: backend-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: lab-09
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
  - to:
    - podSelector:
        matchLabels:
          app: backend-api
    ports:
    - protocol: TCP
      port: 80
EOF
```

### Verification

```bash
kubectl exec -n lab-09 -l app=frontend-client -- curl -s --connect-timeout 5 http://backend-svc
# Should return nginx default page
```
