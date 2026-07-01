## Solution: App of Apps — Child App References Non-Existent Project

### Root Cause
`child-app-2` is assigned to `project: restricted-project` which does not exist in ArgoCD. Without a valid AppProject, ArgoCD denies the application with a PermissionDenied error.

### Step-by-Step Fix

1. Identify the broken child app:
   ```bash
   argocd app list
   argocd proj list
   ```
2. Option A — Change child-app-2 to use project `default`
3. Option B — Create the `restricted-project` AppProject with proper permissions

### Fixed YAML — apps/child-app-2.yaml (Option A)
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: child-app-2
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: helm-guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: child-ns-2
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Fixed YAML — AppProject (Option B)
```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: restricted-project
  namespace: argocd
spec:
  description: "Restricted project for child apps"
  sourceRepos:
    - 'https://github.com/argoproj/argocd-example-apps.git'
  destinations:
    - namespace: '*'
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
```

### Verification
```bash
argocd app list
# child-app-2: Status: Synced, Health: Healthy
argocd app get child-app-2
argocd proj list
```
