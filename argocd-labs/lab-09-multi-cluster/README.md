## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (applies broken Application manifest)
2. Check ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8443:443`
3. Open https://localhost:8443 (admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
4. See the app status (OutOfSync/Degraded/Error)
5. Debug: `argocd app get <app-name>`, check events
6. Fix the YAML, re-sync, verify. Check `solution.md` if stuck

---

# Lab 09: Multi-Cluster Deployment Failure

## Difficulty: ⭐⭐⭐ Hard

## Scenario
An ArgoCD Application is configured to deploy to a remote production cluster. The cluster secret has an expired bearer token and an unreachable API server URL.

## Error Output
```
$ argocd app get multi-cluster-app
Name:               argocd/multi-cluster-app
Status:             Unknown
Health:             Unknown
Conditions:
  ComparisonError   Cluster https://10.0.0.99:6443 has connection error: dial tcp 10.0.0.99:6443: i/o timeout

$ argocd cluster list
SERVER                          NAME                 VERSION  STATUS      MESSAGE
https://kubernetes.default.svc  in-cluster           1.28     Successful
https://10.0.0.99:6443          production-cluster            Failed      dial tcp 10.0.0.99:6443: connect: connection refused
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Check cluster: `argocd cluster list`
3. Check app: `argocd app get multi-cluster-app`
4. Fix the cluster connection (URL + credentials)

## Hints
<details>
<summary>Hint 1</summary>
The cluster URL 10.0.0.99:6443 is unreachable. Update the destination to a valid cluster.
</details>

<details>
<summary>Hint 2</summary>
The bearer token in the cluster secret is expired. Either re-register the cluster with `argocd cluster add` or update the secret with a valid token. For this lab, switch to in-cluster.
</details>
