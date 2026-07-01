# Lab 15 - Helm Diff False Positives

## Root Cause

The `helm-diff` plugin reports changes on every run even when nothing has actually
changed. This is caused by:
1. Non-deterministic output ordering in rendered manifests (need `--normalize-manifests`)
2. Server-side defaulted fields appearing in live resources but not in chart templates
   (need ignore annotations to suppress known diffs)

## Symptoms

- `helm diff upgrade` always shows changes even with no value modifications
- Diffs show reordering of YAML keys or fields that were never in the template
- CI/CD pipelines always detect "drift" and trigger unnecessary deployments
- Fields like `status`, `creationTimestamp`, or defaulted values appear in diff

## Fix Steps

1. Use `--normalize-manifests` flag with `helm diff` to normalize output ordering
2. Add ignore annotations in chart templates for known server-defaulted fields

## Corrected Approach

Use normalize flag:
```bash
# Run diff with normalization
helm diff upgrade myapp ./mychart --normalize-manifests

# Or set as default in alias
alias helm-diff="helm diff upgrade --normalize-manifests"
```

Add annotations to suppress known false-positive diffs in templates:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
  annotations:
    helm-diff/ignore: "creationTimestamp,resourceVersion,uid"
```

For helm-diff plugin configuration:
```bash
# Suppress specific fields globally
helm diff upgrade myapp ./mychart \
  --normalize-manifests \
  --suppress-secrets \
  --three-way-merge
```

## Verification

```bash
# Install the chart
helm install myapp ./mychart

# Run diff - should show NO changes
helm diff upgrade myapp ./mychart --normalize-manifests

# Make an actual change and verify diff shows only that change
helm diff upgrade myapp ./mychart --normalize-manifests --set replicaCount=3

# Verify in CI/CD
DIFF_OUTPUT=$(helm diff upgrade myapp ./mychart --normalize-manifests)
if [ -z "$DIFF_OUTPUT" ]; then
  echo "No changes detected - skipping deploy"
fi
```

## Key Takeaways

- `--normalize-manifests` eliminates false positives from field ordering
- Server-defaulted fields will always show in diff unless suppressed
- Use `--three-way-merge` for accurate comparison against live state
- Build CI/CD pipelines to handle "no diff" case gracefully
