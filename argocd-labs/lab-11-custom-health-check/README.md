# Lab 11: Custom Lua Health Check — Perpetual "Progressing" State

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your platform team has deployed a custom CRD (`DatabaseCluster` from `databases.example.com/v1alpha1`) managed by a third-party operator. ArgoCD has been configured with a custom Lua health check script so it can understand the health semantics of this CRD. However, ArgoCD permanently reports the resource as **"Progressing"** even though the operator has reconciled the resource and it is fully ready.

The on-call engineer has verified:
- The `DatabaseCluster` operator is running and has reconciled the resource
- The CR's `.status.phase` is `Running` and `.status.conditions` show `Ready=True`
- ArgoCD Application sync succeeded but health never transitions to `Healthy`

## Observed Behavior

```
$ argocd app get database-app
Name:               argocd/database-app
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          databases
URL:                https://argocd.example.com/applications/database-app
Repo:               https://git.example.com/platform/database-manifests.git
Target:             main
Path:               overlays/production
SyncWindow:         Sync Allowed
Sync Policy:        Automated
Sync Status:        Synced to main (a3b8c1d)
Health Status:      Progressing

GROUP                    KIND             NAMESPACE   NAME              STATUS   HEALTH       HOOK  MESSAGE
databases.example.com    DatabaseCluster  databases   prod-postgres     Synced   Progressing        

$ argocd app resources database-app --kind DatabaseCluster
GROUP                    KIND             NAMESPACE   NAME              STATUS   HEALTH
databases.example.com    DatabaseCluster  databases   prod-postgres     Synced   Progressing

$ kubectl get databasecluster prod-postgres -n databases -o jsonpath='{.status.phase}'
Running

$ kubectl get databasecluster prod-postgres -n databases -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}'
True

$ kubectl get cm argocd-cm -n argocd -o yaml | grep -A 30 "resource.customizations.health"
resource.customizations.health.databases.example.com_DatabaseCluster: |
  hs = {}
  if obj.status ~= nil then
    if obj.status.conditions ~= nil then
      for i, condition in ipairs(obj.status.conditions) do
        if condition.type == "Ready" and condition.status == "True" then
          hs.Status = "Healthy"
          hs.Message = "Database cluster is ready"
          return hs
        end
      end
    end
  end
  hs.Status = "Progressing"
  hs.Message = "Waiting for database cluster to become ready"
  return hs
```

The ConfigMap health check Lua script **looks** correct when extracted from ArgoCD logs, but the actual `argocd-cm` contains multiple subtle errors preventing it from working.

## Your Task

1. Identify why the custom Lua health check never returns `Healthy`
2. Find ALL bugs in the health check configuration (there are 4)
3. Fix the configuration and verify ArgoCD reports `Healthy`

## Files

- `application.yaml` — ArgoCD Application resource for the database app
- `argocd-cm-health.yaml` — ConfigMap patch with broken Lua health check
- `custom-resource.yaml` — The DatabaseCluster CRD instance with correct status

## Hints

<details>
<summary>Hint 1</summary>
The GVK key format in `resource.customizations.health.<key>` must match exactly how ArgoCD resolves it. Check if the API group and Kind match the actual CRD registration. Is it `DatabaseCluster` or `databaseclusters`? What about the version — does ArgoCD use `Group_Kind` or `Group/Version_Kind`?
</details>

<details>
<summary>Hint 2</summary>
Lua multiline strings use `[[` and `]]` delimiters. If the YAML value contains `]]` or the Lua script uses incorrect quoting for multiline, the script may silently fail to parse. Check for YAML escaping issues and whether the Lua string block is properly terminated.
</details>

<details>
<summary>Hint 3</summary>
ArgoCD Lua health checks must return a table with specific field names. The correct fields are `status` and `message` (lowercase), not `Status` and `Message` (capitalized). Check the ArgoCD documentation for the exact return value format.
</details>

## Useful Commands

```bash
# Check ArgoCD ConfigMap for health customizations
kubectl get cm argocd-cm -n argocd -o yaml

# View ArgoCD application health details
argocd app get database-app
argocd app get database-app --output json | jq '.status.health'

# Check resource tree health
argocd app resources database-app

# Force ArgoCD to re-evaluate health
argocd app get database-app --refresh

# Check ArgoCD server logs for Lua errors
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=100 | grep -i lua
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=100 | grep -i health

# Describe the CRD to get correct GVK
kubectl get crd databaseclusters.databases.example.com -o yaml | head -30

# Check actual resource status
kubectl get databasecluster prod-postgres -n databases -o yaml

# Verify argocd-cm was applied correctly
kubectl describe cm argocd-cm -n argocd

# Restart ArgoCD controller after ConfigMap change
kubectl rollout restart deployment argocd-application-controller -n argocd

# Check if resource customization is detected
argocd admin settings resource-overrides health databases.example.com/DatabaseCluster
```

## What You'll Learn

- ArgoCD custom Lua health check authoring and GVK matching
- Lua syntax debugging in YAML-embedded scripts
- ArgoCD resource customization key format (`Group_Kind` not `Group/Kind`)
- Correct return value format for health check scripts
- How ArgoCD resolves CRD health when no built-in check exists
