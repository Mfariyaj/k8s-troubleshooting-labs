# Lab 04 - Hook Weight Ordering

## Root Cause

Helm hooks execute in order of their weight (lowest first). The current configuration has
the Job hook (which needs a database secret) with a lower weight than the Secret hook that
creates the credentials. This means the Job runs before the Secret exists, causing a failure.

Fix: Set Secret weight to 0 (runs first) and Job weight to 5 (runs after).

## Symptoms

- Pre-install/pre-upgrade hooks fail
- Job pod shows "secret not found" or "CreateContainerConfigError"
- Helm install hangs at "waiting for hook to complete" then times out
- `kubectl get pods` shows hook Job in Error state

## Fix Steps

1. Open the Secret hook template
2. Set its `helm.sh/hook-weight` to `"0"` (runs first)
3. Open the Job hook template
4. Set its `helm.sh/hook-weight` to `"5"` (runs after secret)

## Corrected Configuration

Secret template (`templates/pre-install-secret.yaml`):
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "mychart.fullname" . }}-db-creds
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "0"
    "helm.sh/hook-delete-policy": before-hook-creation
type: Opaque
data:
  password: {{ .Values.db.password | b64enc }}
```

Job template (`templates/pre-install-job.yaml`):
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "mychart.fullname" . }}-db-migrate
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "5"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    spec:
      containers:
        - name: migrate
          image: {{ .Values.migration.image }}
      restartPolicy: Never
```

## Verification

```bash
# Dry-run to verify hook ordering
helm install myapp ./mychart --dry-run --debug | grep -A 5 "hook-weight"

# Install and watch hooks
helm install myapp ./mychart
kubectl get pods -w | grep "pre-install"

# Verify Job succeeded
kubectl get jobs | grep db-migrate
```

## Key Takeaways

- Hook weights are strings, executed lowest-to-highest numerically
- Dependencies between hooks must be expressed via weight ordering
- Use `helm.sh/hook-delete-policy` to clean up completed hooks
- Test hook ordering with `--dry-run --debug`
