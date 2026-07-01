## Solution: Resource Exclusion — Overly Broad ConfigMap Exclusion

### Root Cause
The `argocd-cm` ConfigMap has a `resource.exclusions` rule that excludes ALL ConfigMaps across all clusters (`clusters: [".*"]`). This prevents ArgoCD from managing ConfigMaps the app needs, causing failures when the Deployment references a missing ConfigMap.

### Step-by-Step Fix

1. Identify the missing resource:
   ```bash
   argocd app resources resource-exclusion-app
   kubectl get cm -n resource-exclusion-lab
   ```
2. Check the exclusion rules:
   ```bash
   kubectl get cm argocd-cm -n argocd -o yaml
   ```
3. Narrow the exclusion to only system namespaces

### Fixed YAML — argocd-cm.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
  resource.exclusions: |
    - apiGroups:
        - ""
      kinds:
        - ConfigMap
      clusters:
        - ".*"
      namespaces:
        - kube-system
        - kube-public
  url: https://argocd.example.com
```

### Verification
```bash
# Restart argocd-server to pick up ConfigMap changes
kubectl rollout restart deployment argocd-server -n argocd
kubectl rollout restart deployment argocd-application-controller -n argocd

argocd app sync resource-exclusion-app
argocd app resources resource-exclusion-app
# Should list both Deployment and ConfigMap
kubectl get cm app-config -n resource-exclusion-lab
```
