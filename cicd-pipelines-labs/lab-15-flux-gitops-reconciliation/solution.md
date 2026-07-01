# Solution: Lab 15 - Flux GitOps Reconciliation Failure

## Problem

Flux CD fails to reconcile the Git repository with the cluster. Kustomizations report
"path not found" or HelmReleases fail with "values secret not found".

## Diagnosis

```bash
# Check Flux source status
flux get sources git
kubectl get gitrepository -n flux-system

# Check Kustomization status
flux get kustomizations
kubectl describe kustomization <name> -n flux-system

# Check HelmRelease status
flux get helmreleases
kubectl describe helmrelease <name> -n flux-system

# Look for:
# - "path not found" in Kustomization
# - Wrong interval causing stale state
# - Missing valuesFrom secret
```

## Root Cause

1. **Wrong Kustomization path**: The `spec.path` in the Kustomization doesn't match
   the actual directory structure in the Git repository.
2. **Interval too long or zero**: The reconciliation interval is misconfigured,
   preventing Flux from detecting changes.
3. **Missing valuesFrom secret**: HelmRelease references a secret for values
   substitution that doesn't exist in the cluster.

## Fix

### Step 1: Fix Kustomization path

```yaml
# flux-system/kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: app
  namespace: flux-system
spec:
  # BROKEN: path: ./deploy/production
  # FIXED: Match actual repo directory structure
  path: ./k8s/production
  sourceRef:
    kind: GitRepository
    name: flux-system
  # FIXED: Set reasonable interval
  interval: 5m
  prune: true
```

### Step 2: Fix interval

```yaml
spec:
  # BROKEN: interval: 0s  or interval: 24h
  # FIXED: Reasonable reconciliation interval
  interval: 5m
```

### Step 3: Create the valuesFrom secret

```bash
# Create the secret that HelmRelease references
kubectl create secret generic helm-values \
  --from-literal=replicaCount=3 \
  --from-literal=image.tag=v1.2.3 \
  -n flux-system

# Or from a file:
kubectl create secret generic helm-values \
  --from-file=values.yaml=production-values.yaml \
  -n flux-system
```

### HelmRelease valuesFrom reference:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
spec:
  valuesFrom:
    - kind: Secret
      name: helm-values  # This secret must exist
      valuesKey: values.yaml
```

## Verification

```bash
# Force reconciliation
flux reconcile kustomization app

# Check status
flux get kustomizations
flux get helmreleases

# Verify resources are deployed
kubectl get all -n app-namespace

# Check events for errors
kubectl events -n flux-system --for kustomization/app
```

## Key Takeaways

- Kustomization `path` must exactly match the directory in the Git repo
- Interval of `0s` disables automatic reconciliation
- `valuesFrom` secrets must exist BEFORE the HelmRelease is applied
- Use `flux reconcile` to force immediate sync after fixing issues
- Check `flux get sources git` to ensure the repo is accessible
