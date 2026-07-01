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
