# Lab 06: Resource Exclusion

## Difficulty: ⭐⭐⭐ Hard

## Scenario
ArgoCD is configured with resource exclusions in argocd-cm ConfigMap. A broad regex pattern accidentally excludes ConfigMaps that the application needs, causing the app to fail.

## Error Output
```
$ argocd app get resource-exclusion-app
Name:               argocd/resource-exclusion-app
Status:             Synced
Health:             Degraded

$ argocd app resources resource-exclusion-app
GROUP  KIND        NAMESPACE              NAME            STATUS  HEALTH
apps   Deployment  resource-exclusion-lab nginx-with-cfg  Synced  Degraded

# Notice: ConfigMap is NOT listed despite being in the source!

$ kubectl get cm -n resource-exclusion-lab
No resources found in resource-exclusion-lab namespace.
```

## Your Task
1. Deploy the lab: `./deploy.sh`
2. Check the app: `argocd app get resource-exclusion-app`
3. Notice the missing ConfigMap resource
4. Find and fix the exclusion rule in argocd-cm

## Hints
<details>
<summary>Hint 1</summary>
Check argocd-cm: kubectl get cm argocd-cm -n argocd -o yaml. Look at resource.exclusions.
</details>

<details>
<summary>Hint 2</summary>
The exclusion regex ".*" for kind ConfigMap excludes ALL ConfigMaps from being managed.
</details>
