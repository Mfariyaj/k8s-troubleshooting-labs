## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (applies broken Application manifest)
2. Check ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8443:443`
3. Open https://localhost:8443 (admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
4. See the app status (OutOfSync/Degraded/Error)
5. Debug: `argocd app get <app-name>`, check events
6. Fix the YAML, re-sync, verify. Check `solution.md` if stuck

---

# Lab 10: RBAC Policy Broken

## Difficulty: ⭐⭐⭐ Hard

## Scenario
ArgoCD RBAC policies are configured in argocd-rbac-cm, but the policy has syntax errors. Users in the 'developer-team' group cannot sync applications despite having an RBAC rule that should allow it.

## Error Output
```
$ argocd app sync rbac-test-app --auth-token $DEV_TOKEN
FATA[0001] rpc error: code = PermissionDenied desc = permission denied: applications, sync, team-project/rbac-test-app, sub: developer-team

$ argocd admin settings rbac validate --policy-file policy.csv
Policy file has errors:
  line 3: wrong number of fields in policy rule (expected 6, got 4)
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Try to sync: `argocd app sync rbac-test-app`
3. Validate RBAC: `kubectl get cm argocd-rbac-cm -n argocd -o yaml`
4. Fix the RBAC policy syntax

## Hints
<details>
<summary>Hint 1</summary>
Look at line 3 of policy.csv - it's missing commas between fields.
</details>

<details>
<summary>Hint 2</summary>
Correct format: `p, role:developer, applications, create, default/*, allow`. Also note the policy uses project 'default' but the app is in 'team-project'.
</details>
