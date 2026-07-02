## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (applies broken Application manifest)
2. Check ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8443:443`
3. Open https://localhost:8443 (admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
4. See the app status (OutOfSync/Degraded/Error)
5. Debug: `argocd app get <app-name>`, check events
6. Fix the YAML, re-sync, verify. Check `solution.md` if stuck

---

# Lab 02: Health Degraded

## Difficulty: ⭐ Easy

## Scenario
An ArgoCD Application syncs successfully but the health status shows "Degraded". The deployment never becomes healthy.

## Error Output
```
$ argocd app get health-degraded-app
Name:               argocd/health-degraded-app
Status:             Synced
Health:             Degraded

GROUP  KIND        NAME           STATUS  HEALTH
apps   Deployment  nginx-app      Synced  Degraded
       Service     nginx-app-svc  Synced  Healthy

$ argocd app resources health-degraded-app
NAMESPACE           NAME           GROUP  KIND        HEALTH
health-degraded-lab nginx-app      apps   Deployment  Degraded
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Check health: `argocd app get health-degraded-app`
3. Identify why the deployment is degraded
4. Fix the root cause

## Hints
<details>
<summary>Hint 1</summary>
Check the pod events with kubectl describe pod.
</details>

<details>
<summary>Hint 2</summary>
The container image doesn't exist. What image tag should be used?
</details>
