## Solution: Custom Health Check — Perpetual "Progressing" State

### Root Cause
Four bugs in the Lua health check configuration:
1. **Wrong GVK key format**: Uses `databases.example.com/v1alpha1_DatabaseCluster` — ArgoCD expects `databases.example.com_DatabaseCluster` (Group_Kind, no version)
2. **Capitalized return fields**: `hs.Status` and `hs.Message` must be lowercase `hs.status` and `hs.message`
3. **Wrong field path**: Script checks `obj.status.conditions` but the CRD nests conditions under `obj.status.clusterStatus.conditions`
4. **YAML/Lua conflict**: `]]` in a Lua comment can break YAML parsing of block scalars

### Step-by-Step Fix

1. Check current health status:
   ```bash
   argocd app get database-app
   kubectl get databasecluster prod-postgres -n databases -o yaml
   ```
2. Fix the ConfigMap key, return fields, field path, and remove `]]`

### Fixed YAML — argocd-cm-health.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
  resource.customizations.health.databases.example.com_DatabaseCluster: |
    hs = {}
    if obj.status ~= nil then
      if obj.status.clusterStatus ~= nil and obj.status.clusterStatus.conditions ~= nil then
        for i, condition in ipairs(obj.status.clusterStatus.conditions) do
          if condition.type == "Ready" and condition.status == "True" then
            hs.status = "Healthy"
            hs.message = "Database cluster is ready"
            return hs
          end
        end
      end
      if obj.status.phase == "Running" then
        hs.status = "Healthy"
        hs.message = obj.status.phase
        return hs
      end
    end
    hs.status = "Progressing"
    hs.message = "Waiting for database cluster to become ready"
    return hs
```

### Verification
```bash
kubectl apply -f argocd-cm-health.yaml
kubectl rollout restart deployment argocd-application-controller -n argocd
argocd app get database-app --refresh
# Health Status: Healthy
```
