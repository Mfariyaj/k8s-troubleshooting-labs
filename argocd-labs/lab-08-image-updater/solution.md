## Solution: Image Updater Not Working — Wrong Annotation Key

### Root Cause
The Application uses annotation key `argocd-image-updater.argoproj.io/images` but the correct key is `argocd-image-updater.argoproj.io/image-list`. The Image Updater ignores the app because it cannot find the expected annotation.

### Step-by-Step Fix

1. Check Image Updater logs:
   ```bash
   kubectl logs -n argocd deployment/argocd-image-updater | grep "No images"
   ```
2. Fix the annotation key:
   ```bash
   kubectl annotate application image-updater-app -n argocd \
     argocd-image-updater.argoproj.io/images- \
     argocd-image-updater.argoproj.io/image-list="nginx=nginx"
   ```

### Fixed YAML
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: image-updater-app
  namespace: argocd
  annotations:
    argocd-image-updater.argoproj.io/image-list: nginx=nginx
    argocd-image-updater.argoproj.io/nginx.update-strategy: latest
    argocd-image-updater.argoproj.io/write-back-method: git
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: image-updater-lab
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Verification
```bash
kubectl logs -n argocd deployment/argocd-image-updater --tail=20
# Should show: "Processing image nginx" instead of "No images configured"
argocd app get image-updater-app
# Status: Synced, Health: Healthy
```
