## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (applies broken Application manifest)
2. Check ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8443:443`
3. Open https://localhost:8443 (admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
4. See the app status (OutOfSync/Degraded/Error)
5. Debug: `argocd app get <app-name>`, check events
6. Fix the YAML, re-sync, verify. Check `solution.md` if stuck

---

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
