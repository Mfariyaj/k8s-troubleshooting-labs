# Lab 05: App of Apps Failure

## Difficulty: ⭐⭐ Medium

## Scenario
An App-of-Apps pattern is used. The parent application deploys child applications, but one child app is assigned to a non-existent project and fails to create.

## Error Output
```
$ argocd app get parent-app
Name:               argocd/parent-app
Status:             Synced
Health:             Degraded

$ argocd app get child-app-2
FATA[0001] rpc error: code = PermissionDenied desc = application 'child-app-2' in project 'restricted-project' is not permitted

$ argocd app list
NAME          CLUSTER                         NAMESPACE  PROJECT    STATUS     HEALTH
parent-app    https://kubernetes.default.svc  argocd     default    Synced     Healthy
child-app-1   https://kubernetes.default.svc  child-ns   default    Synced     Healthy
child-app-2   https://kubernetes.default.svc  child-ns   restricted-project  Unknown  Unknown
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Check parent: `argocd app get parent-app`
3. List all apps: `argocd app list`
4. Fix the child application that's in the wrong project

## Hints
<details>
<summary>Hint 1</summary>
Check what projects exist: argocd proj list
</details>

<details>
<summary>Hint 2</summary>
child-app-2 references project 'restricted-project' which doesn't exist. Change it to 'default'.
</details>
