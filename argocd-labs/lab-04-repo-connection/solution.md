## Solution: Repo Connection Failure — Invalid URL and Expired Token

### Root Cause
Two issues prevent repository access:
1. `repoURL` points to `https://github.com/internal-corp/private-manifests.git` which doesn't exist
2. The token in the repo Secret is expired/invalid (`EXPIRED_GITHUB_TOKEN_REPLACE_ME_abc123def456`)

### Step-by-Step Fix

1. Diagnose the connection error:
   ```bash
   argocd repo list
   argocd app get repo-connection-app
   ```
2. Fix the repoURL to point to a valid repository
3. Update the Secret with a valid token (or switch to a public repo)

### Fixed YAML — application.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: repo-connection-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: repo-connection-lab
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```

### Fixed YAML — repo-secret.yaml (for private repos)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: https://github.com/your-org/your-repo.git
  username: deploy-bot
  password: ghp_VALID_PERSONAL_ACCESS_TOKEN
```

### Verification
```bash
argocd repo list
# STATUS: Successful
argocd app get repo-connection-app
# Status: Synced, Health: Healthy
argocd app sync repo-connection-app
```
