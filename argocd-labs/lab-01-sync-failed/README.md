## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (applies broken Application manifest)
2. Check ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8443:443`
3. Open https://localhost:8443 (admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
4. See the app status (OutOfSync/Degraded/Error)
5. Debug: `argocd app get <app-name>`, check events
6. Fix the YAML, re-sync, verify. Check `solution.md` if stuck

---

# Lab 01: Sync Failed

## Difficulty: ⭐ Easy

## Scenario
An ArgoCD Application has been deployed but sync continuously fails. The application never reaches a healthy state.

## Error Output
```
$ argocd app get sync-failed-app
Name:               argocd/sync-failed-app
Status:             OutOfSync
Health:             Missing
Sync Status:        ComparisonError

CONDITION     MESSAGE
ComparisonError  rpc error: code = Unknown desc = `git ls-remote` failed: repository not found or path does not exist
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Check application status: `argocd app get sync-failed-app`
3. Identify why sync is failing
4. Fix the application configuration

## Hints
<details>
<summary>Hint 1</summary>
Check the source path in the Application spec.
</details>

<details>
<summary>Hint 2</summary>
The path specified doesn't exist in the repository. What's the correct path?
</details>
