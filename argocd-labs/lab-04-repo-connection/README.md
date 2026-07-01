# Lab 04: Repo Connection Failure

## Difficulty: ⭐⭐ Medium

## Scenario
An ArgoCD Application points to a private Git repository. The repository credentials are stored as a Secret, but syncs fail with authentication errors.

## Error Output
```
$ argocd app get repo-connection-app
Name:               argocd/repo-connection-app
Status:             Unknown
Health:             Unknown
Conditions:
  ComparisonError   rpc error: code = Unknown desc = authentication required

$ argocd repo list
TYPE  NAME  REPO                                                    INSECURE  OCI    LFS    CREDS  STATUS      MESSAGE
git         https://github.com/internal-corp/private-manifests.git  false     false  false  false  Failed      authentication required
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Check repo status: `argocd repo list`
3. Check application: `argocd app get repo-connection-app`
4. Fix the repository credentials

## Hints
<details>
<summary>Hint 1</summary>
The repository URL might not even exist. Check if the URL is correct.
</details>

<details>
<summary>Hint 2</summary>
The token in the Secret has expired. Update with a valid token or point to a public repo.
</details>
