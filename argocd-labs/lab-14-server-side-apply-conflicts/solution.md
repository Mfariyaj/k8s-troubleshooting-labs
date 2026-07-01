## Solution: Server-Side Apply Conflicts — Constant OutOfSync with HPA

### Root Cause
Four bugs cause the HPA/ArgoCD oscillation:
1. **Wrong jqPathExpressions syntax**: Uses JSON Pointer `/spec/replicas` inside `jqPathExpressions` — should be `.spec.replicas` (jq syntax)
2. **ServerSideApply not enabled**: Without `ServerSideApply=true`, ArgoCD does full-object apply and doesn't respect field managers
3. **Missing RespectIgnoreDifferences**: Needed for auto-sync to honor ignoreDifferences during normalization
4. **ignoreDifferences uses wrong field**: The config mixes jsonPointers and jqPathExpressions formats

### Step-by-Step Fix

1. Identify the drift:
   ```bash
   argocd app diff scaling-app
   argocd app get scaling-app --output json | jq '.status.conditions'
   ```
2. Fix jqPathExpressions to use jq syntax
3. Enable ServerSideApply and RespectIgnoreDifferences

### Fixed YAML — application.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scaling-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://git.example.com/apps/web-frontend.git
    targetRevision: main
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: scaling-app
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jqPathExpressions:
        - .spec.replicas
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
      - RespectIgnoreDifferences=true
```

### Fixed YAML — argocd-cm-diffing.yaml (global config)
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  resource.customizations.ignoreDifferences.apps_Deployment: |
    jqPathExpressions:
      - .spec.replicas
```

### Verification
```bash
kubectl apply -f application.yaml
argocd app get scaling-app --refresh
# Sync Status: Synced (no longer oscillating)
argocd app diff scaling-app
# No differences detected for spec.replicas
```
