## Solution: RBAC Policy Broken — Syntax Errors and Project Mismatch

### Root Cause
Two issues in `argocd-rbac-cm`:
1. Line 3 has invalid syntax — missing commas: `create default/* allow` should be `create, default/*, allow`
2. Policy grants permissions on `default/*` but the app is in `team-project` — rules needed for both

### Step-by-Step Fix

1. Validate the RBAC policy:
   ```bash
   kubectl get cm argocd-rbac-cm -n argocd -o yaml
   ```
2. Fix comma-separated syntax on line 3
3. Add permissions for `team-project/*`

### Fixed YAML — argocd-rbac-cm.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-rbac-cm
    app.kubernetes.io/part-of: argocd
data:
  policy.csv: |
    p, role:developer, applications, sync, default/*, allow
    p, role:developer, applications, get, default/*, allow
    p, role:developer, applications, create, default/*, allow
    p, role:developer, logs, get, default/*, allow
    p, role:developer, applications, sync, team-project/*, allow
    p, role:developer, applications, get, team-project/*, allow
    p, role:developer, applications, create, team-project/*, allow
    g, developer-team, role:developer
  policy.default: role:readonly
  scopes: '[groups]'
```

### Verification
```bash
argocd admin settings rbac validate \
  --policy-file <(kubectl get cm argocd-rbac-cm -n argocd -o jsonpath='{.data.policy\.csv}')
# No errors

argocd admin settings rbac can role:developer sync applications 'team-project/rbac-test-app'
# Yes
argocd app sync rbac-test-app
```
