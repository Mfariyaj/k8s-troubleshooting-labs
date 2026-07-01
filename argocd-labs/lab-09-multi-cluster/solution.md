## Solution: Multi-Cluster Deployment — Unreachable Cluster

### Root Cause
Three issues with the remote cluster configuration:
1. Cluster URL `https://10.0.0.99:6443` is unreachable (connection refused)
2. Bearer token is expired (`EXPIRED_TOKEN_2024_01_01.invalid_signature`)
3. CA certificate data is fake/invalid

### Step-by-Step Fix

1. Verify the cluster connection:
   ```bash
   argocd cluster list
   argocd app get multi-cluster-app
   ```
2. Fix by switching to in-cluster (simplest for lab):
   ```bash
   kubectl patch application multi-cluster-app -n argocd --type merge \
     -p '{"spec":{"destination":{"server":"https://kubernetes.default.svc"}}}'
   ```
3. Or re-register the real cluster: `argocd cluster add <context-name>`

### Fixed YAML — application.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: multi-cluster-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: multi-cluster-lab
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Fixed cluster-secret.yaml (for real remote clusters)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: production-cluster-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: production-cluster
  server: https://REAL_CLUSTER_IP:6443
  config: |
    {
      "bearerToken": "VALID_TOKEN",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "VALID_BASE64_CA_CERT"
      }
    }
```

### Verification
```bash
argocd cluster list
# STATUS: Successful
argocd app get multi-cluster-app
# Status: Synced, Health: Healthy
```
