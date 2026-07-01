# Lab 03: Hook Failure

## Difficulty: ⭐⭐ Medium

## Scenario
An ArgoCD Application has a PreSync hook (database migration Job) that fails. Since the hook fails, the main sync never proceeds.

## Error Output
```
$ argocd app sync hook-failure-app
FATA[0032] Operation failed: one or more sync tasks are not valid: 
  PreSync hook job/pre-sync-db-migration failed: BackoffLimitExceeded

$ argocd app get hook-failure-app
Name:               argocd/hook-failure-app
Sync Status:        OutOfSync
Health:             Missing
Operation:          Sync
Phase:              Failed
Message:            one or more synchronization tasks are not valid
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Trigger sync: `argocd app sync hook-failure-app`
3. Identify why the pre-sync hook fails
4. Fix the hook Job so sync can proceed

## Hints
<details>
<summary>Hint 1</summary>
Check the Job's pod status and events: kubectl describe job pre-sync-db-migration -n hook-failure-lab
</details>

<details>
<summary>Hint 2</summary>
The Job uses a non-existent image tag and backoffLimit is 0 (no retries).
</details>
