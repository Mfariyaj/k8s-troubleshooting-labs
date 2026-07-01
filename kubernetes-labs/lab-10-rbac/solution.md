## Solution: RBAC Permission Errors

### Root Cause

Two issues with the RBAC configuration:
1. The RoleBinding references ServiceAccount `wrong-sa` but the pod uses `app-sa`.
2. The Role only grants `get` on `configmaps`, but the pod runs `kubectl get pods` which needs `list` and `get` on `pods`.

### Diagnosis

```bash
kubectl get pods -n lab-10
kubectl logs -n lab-10 -l app=controller-app
kubectl get rolebinding pod-reader-binding -n lab-10 -o yaml
kubectl get role pod-reader -n lab-10 -o yaml
```

Logs show: `Error from server (Forbidden): pods is forbidden`

### Fix

Fix both the Role and RoleBinding:

```bash
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: lab-10
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: lab-10
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: lab-10
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
EOF
```

### Fixed YAML

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: lab-10
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: lab-10
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: lab-10
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### Verification

```bash
kubectl auth can-i list pods -n lab-10 --as=system:serviceaccount:lab-10:app-sa
# Should return "yes"
kubectl logs -n lab-10 -l app=controller-app
# Should show pod listing without Forbidden errors
```
