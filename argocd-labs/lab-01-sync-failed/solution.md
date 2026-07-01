## Solution: Sync Failed — Invalid Source Path

### Root Cause
The Application's `spec.source.path` is set to `/manifests-typo` which does not exist in the repository. The correct path in the `argocd-example-apps` repo is `guestbook`. The target namespace also needs to be created.

### Step-by-Step Fix

1. Check current application status:
   ```bash
   argocd app get sync-failed-app
   ```
2. Identify the invalid path in the Application spec
3. Patch the Application to use the correct path:
   ```bash
   kubectl patch application sync-failed-app -n argocd --type merge \
     -p '{"spec":{"source":{"path":"guestbook"}}}'
   ```
4. Ensure the namespace exists (CreateNamespace=true handles this)

### Fixed YAML
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sync-failed-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: sync-failed-lab
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Verification
```bash
argocd app get sync-failed-app
# Status: Synced, Health: Healthy
argocd app sync sync-failed-app
kubectl get pods -n sync-failed-lab
```
