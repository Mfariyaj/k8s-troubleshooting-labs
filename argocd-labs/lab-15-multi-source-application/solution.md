## Solution: Multi-Source Application — Helm Values from Separate Repo Fails

### Root Cause
Four bugs prevent the multi-source Application from generating manifests:
1. **$ref mismatch**: valueFiles use `$values/...` but source[1] defines `ref: valuesRef` — must match (`$valuesRef` or change ref to `values`)
2. **Invalid chart version**: `2.x.x` is not valid Helm semver — use `2.1.0` or `~2.0`
3. **ref name mismatch**: The `ref` field and `$ref` prefix in valueFiles must be identical
4. **Wrong targetRevision**: Branch `release-v2.0` doesn't exist — should be `release/v2.0` or `main`

### Step-by-Step Fix

1. Check Application conditions:
   ```bash
   argocd app get multi-source-app
   kubectl get application multi-source-app -n argocd -o jsonpath='{.status.conditions}'
   ```
2. Fix the ref name to match between sources
3. Fix the chart version to valid semver
4. Fix the targetRevision to an existing branch/tag

### Fixed YAML — application.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: multi-source-app
  namespace: argocd
spec:
  project: default
  sources:
    # Source 0: Helm chart from chart repository
    - repoURL: https://charts.example.com
      chart: platform-service
      targetRevision: "2.1.0"
      helm:
        releaseName: platform-service
        valueFiles:
          - "$values/environments/production/values.yaml"
          - "$values/environments/production/secrets.yaml"
        parameters:
          - name: global.environment
            value: production
          - name: global.cluster
            value: prod-us-east-1

    # Source 1: Values from a separate Git repository
    - repoURL: https://git.example.com/platform/helm-values.git
      targetRevision: "release/v2.0"
      ref: values

  destination:
    server: https://kubernetes.default.svc
    namespace: platform
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
```

### Key Changes
- `ref: valuesRef` → `ref: values` (matches `$values` in valueFiles)
- `targetRevision: "2.x.x"` → `targetRevision: "2.1.0"` (valid semver)
- `targetRevision: "release-v2.0"` → `targetRevision: "release/v2.0"` (correct branch)

### Verification
```bash
kubectl apply -f application.yaml
argocd app get multi-source-app
# Sync Status: Synced, Health: Healthy
argocd app manifests multi-source-app --source=live
# Manifests generated successfully
```
