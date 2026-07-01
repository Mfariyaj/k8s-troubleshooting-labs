# Lab 04: Hook Weight Ordering

## Difficulty: ⭐⭐ Medium

## Scenario

A developer set up Helm hooks for database migration. They have:
- A **pre-install Job** (weight: 5) that runs database migrations — it needs a database credential Secret
- A **pre-install Secret** (weight: 10) that provides the database credentials

The problem: The Job starts BEFORE the Secret exists, causing the pod to fail with `CreateContainerConfigError` because the secretKeyRef cannot be resolved.

Your task: Fix the hook weights so resources are created in the correct order.

## Error Output

```
$ helm install myrelease ./mychart
NAME: myrelease
STATUS: failed
DESCRIPTION: pre-install hook failed: job "myrelease-db-migrate" failed

$ kubectl describe pod myrelease-db-migrate-xxxxx
Events:
  Warning  Failed   <time>  kubelet  Error: secret "myrelease-db-credentials" not found

$ kubectl get events --sort-by=.lastTimestamp
LAST SEEN   TYPE      REASON              OBJECT                           MESSAGE
<time>      Normal   Scheduled           pod/myrelease-db-migrate-xxxxx   Successfully assigned...
<time>      Warning  Failed              pod/myrelease-db-migrate-xxxxx   Error: secret "myrelease-db-credentials" not found
```

## Hints

1. Helm hooks execute in order of their `helm.sh/hook-weight` annotation — lower numbers execute first.
2. The Job (weight: 5) executes before the Secret (weight: 10). The Job needs the Secret to exist first.
3. Swap the weights: give the Secret a lower weight (e.g., 0 or 1) and the Job a higher weight (e.g., 5 or 10).

## Commands

```bash
# Deploy and observe the failure
helm install myrelease ./mychart --dry-run --debug

# On a live cluster, see the actual failure
helm install myrelease ./mychart
kubectl get pods
kubectl describe pod -l job-name=myrelease-db-migrate
```

## Root Cause

Hook weight ordering is wrong:
- Secret has weight `10` (executes second)
- Job has weight `5` (executes first)

The Job references the Secret via `secretKeyRef`, but the Secret doesn't exist yet when the Job starts.

## Fix

Swap the weights so the Secret is created before the Job:

```yaml
# pre-install-secret.yaml - lower weight = created first
annotations:
  "helm.sh/hook": pre-install
  "helm.sh/hook-weight": "0"

# pre-install-job.yaml - higher weight = runs after secret exists
annotations:
  "helm.sh/hook": pre-install
  "helm.sh/hook-weight": "5"
```
