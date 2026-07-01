## Solution: ApplicationSet Generator — Zero Applications Generated

### Root Cause
Five bugs prevent the ApplicationSet from generating applications:
1. **Wrong generator type**: `cluster` (singular) should be `clusters` (plural)
2. **Wrong directory path**: `apps/*` should be `services/*` (matching actual repo structure)
3. **Label selector mismatch**: Selector uses `environment` but secrets have label key `env`
4. **Invalid template function**: `toUpper` doesn't exist in Go templates — use `upper` (sprig) or remove
5. **goTemplate with wrong function**: When goTemplate is enabled, sprig functions are available but `toUpper` is not one of them

### Step-by-Step Fix

1. Check ApplicationSet controller logs:
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-applicationset-controller --tail=50
   ```
2. Fix all five issues in the ApplicationSet spec

### Fixed YAML — applicationset.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: platform-services-set
  namespace: argocd
spec:
  goTemplate: true
  goTemplateOptions: ["missingkey=error"]
  generators:
    - matrix:
        generators:
          - git:
              repoURL: https://git.example.com/platform/services.git
              revision: HEAD
              directories:
                - path: services/*
          - clusters:
              selector:
                matchLabels:
                  env: "production"
  template:
    metadata:
      name: '{{.path.basename}}-{{.name}}'
      namespace: argocd
      labels:
        app.kubernetes.io/managed-by: applicationset-controller
        cluster: '{{.name}}'
        service: '{{.path.basename}}'
    spec:
      project: default
      source:
        repoURL: https://git.example.com/platform/services.git
        targetRevision: HEAD
        path: '{{.path.path}}'
      destination:
        server: '{{.server}}'
        namespace: '{{.path.basename}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
```

### Verification
```bash
kubectl apply -f applicationset.yaml
kubectl get applicationsets -n argocd
kubectl get applications -n argocd -l app.kubernetes.io/managed-by=applicationset-controller
# Should show generated applications (services x clusters)
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-applicationset-controller --tail=20
# No errors
```
