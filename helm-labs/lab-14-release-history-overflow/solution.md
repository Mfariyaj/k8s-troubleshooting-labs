# Lab 14 - Release History Overflow

## Root Cause

Helm stores release history as Kubernetes secrets (one per revision). Without
`--history-max`, history grows unbounded. After many upgrades, the large number of
secrets causes slow operations, etcd storage pressure, and eventually failures.

## Symptoms

- `helm upgrade` becomes increasingly slow
- etcd storage fills up with helm release secrets
- `kubectl get secrets` shows hundreds of `sh.helm.release.v1.*` entries
- Helm operations timeout or OOM
- Error: "UPGRADE FAILED: cannot patch" due to resource limits

## Fix Steps

1. Set `--history-max=10` on all future upgrades to cap stored revisions
2. Clean up existing old release secrets manually

## Corrected Approach

For future upgrades, always set history-max:
```bash
helm upgrade myapp ./mychart --history-max=10
```

Or set as environment default:
```bash
export HELM_MAX_HISTORY=10
```

Clean up old release secrets:
```bash
# List all release secrets
kubectl get secrets -l owner=helm,name=myapp --sort-by=.metadata.creationTimestamp

# Delete old revisions (keep last 10)
kubectl get secrets -l owner=helm,name=myapp \
  --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | \
  head -n -10 | \
  xargs -r kubectl delete secret
```

## Verification

```bash
# Count remaining release secrets
kubectl get secrets -l owner=helm,name=myapp --no-headers | wc -l

# Verify helm history shows limited entries
helm history myapp

# Test upgrade works with history-max
helm upgrade myapp ./mychart --history-max=10

# Verify only 10 secrets remain after subsequent upgrades
kubectl get secrets -l owner=helm,name=myapp --no-headers | wc -l
```

## Key Takeaways

- Always use `--history-max` to prevent unbounded history growth
- Helm stores each revision as a Kubernetes secret in the release namespace
- Old secrets can be manually cleaned with `kubectl delete`
- Set `HELM_MAX_HISTORY` env var for organization-wide defaults
- Consider adding `--history-max` to CI/CD pipelines
