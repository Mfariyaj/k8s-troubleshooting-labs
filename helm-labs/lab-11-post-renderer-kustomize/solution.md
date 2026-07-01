# Lab 11 - Post-Renderer with Kustomize

## Root Cause

The Helm post-render script and Kustomize overlay have three issues:
1. `post-render.sh` is not executable (missing `chmod +x`)
2. Resource names in `kustomization.yaml` don't match the Helm output resource names
3. The `apiVersion` in kustomization.yaml is wrong or missing

## Symptoms

- `helm install --post-renderer ./post-render.sh` fails with "permission denied"
- Kustomize fails with "resource not found" for patch targets
- Error: "unknown apiVersion" in kustomization.yaml
- Post-renderer exits non-zero, aborting Helm install

## Fix Steps

1. Make `post-render.sh` executable: `chmod +x post-render.sh`
2. Fix resource names in `kustomization.yaml` to match Helm-generated names
3. Fix `apiVersion` in `kustomization.yaml`

## Corrected Files

`post-render.sh`:
```bash
#!/bin/bash
# Read stdin from Helm, pipe through kustomize
cat > kustomize/base/all.yaml
kustomize build kustomize/base
```

Make it executable:
```bash
chmod +x post-render.sh
```

`kustomize/base/kustomization.yaml`:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - all.yaml

patches:
  - target:
      kind: Deployment
      name: myrelease-mychart
    patch: |-
      - op: add
        path: /metadata/annotations/custom
        value: "patched"
```

## Verification

```bash
# Verify script is executable
ls -la post-render.sh

# Test post-renderer manually
helm template myapp ./mychart | ./post-render.sh

# Install with post-renderer
helm install myapp ./mychart --post-renderer ./post-render.sh

# Verify patches were applied
kubectl get deployment myrelease-mychart -o jsonpath='{.metadata.annotations}'
```

## Key Takeaways

- Post-render scripts must be executable (`chmod +x`)
- Resource names in kustomization must match Helm's generated names exactly
- Use `helm template` to find exact resource names for kustomize targets
- Kustomize requires `apiVersion: kustomize.config.k8s.io/v1beta1`
