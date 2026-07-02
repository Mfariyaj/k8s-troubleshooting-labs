## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (applies broken Application manifest)
2. Check ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8443:443`
3. Open https://localhost:8443 (admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
4. See the app status (OutOfSync/Degraded/Error)
5. Debug: `argocd app get <app-name>`, check events
6. Fix the YAML, re-sync, verify. Check `solution.md` if stuck

---

# Lab 07: Sync Waves Misconfigured

## Difficulty: ⭐⭐⭐ Hard

## Scenario
An application uses ArgoCD sync waves to order deployments. The web app (wave 1) has an init container that waits for the database, but the database (wave 3) deploys AFTER the app. The app pods are stuck in Init state forever.

## Error Output
```
$ argocd app get sync-waves-app
Name:               argocd/sync-waves-app
Status:             Synced
Health:             Progressing

$ kubectl get pods -n sync-waves-lab
NAME                        READY   STATUS     RESTARTS   AGE
web-app-6d4f5b7c8-abcde    0/1     Init:0/1   0          5m
web-app-6d4f5b7c8-fghij    0/1     Init:0/1   0          5m

# The database pod hasn't been created yet because it's wave 3!
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Check status: `argocd app get sync-waves-app`
3. Observe pods stuck in Init
4. Fix the sync wave ordering

## Hints
<details>
<summary>Hint 1</summary>
Check the sync-wave annotations on each manifest: grep -r "sync-wave" manifests/
</details>

<details>
<summary>Hint 2</summary>
The database should deploy BEFORE the app. DB should be wave 1, app should be wave 2 or 3.
</details>
