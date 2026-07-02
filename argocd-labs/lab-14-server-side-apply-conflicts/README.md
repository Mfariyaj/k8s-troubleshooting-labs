## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (applies broken Application manifest)
2. Check ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8443:443`
3. Open https://localhost:8443 (admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
4. See the app status (OutOfSync/Degraded/Error)
5. Debug: `argocd app get <app-name>`, check events
6. Fix the YAML, re-sync, verify. Check `solution.md` if stuck

---

# Lab 14: Server-Side Apply Conflicts — Constant OutOfSync with HPA

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your team has an ArgoCD-managed Deployment that also has an HPA (Horizontal Pod Autoscaler) controlling its `spec.replicas`. The Application is **constantly oscillating between Synced and OutOfSync** because:

1. ArgoCD sets `spec.replicas: 3` in the manifest
2. HPA scales the Deployment to 5 replicas
3. ArgoCD detects drift and shows OutOfSync
4. If auto-sync is enabled, it reverts replicas back to 3
5. HPA scales back up → infinite loop

The team tried to configure `ignoreDifferences` in the Application to exclude `spec.replicas` from diff detection, but the configuration has multiple errors and Server-Side Apply is not properly enabled.

## Observed Behavior

```
$ argocd app get scaling-app
Name:               argocd/scaling-app
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          scaling-app
Sync Status:        OutOfSync
Health Status:      Healthy
Sync Condition:     <none>

GROUP  KIND        NAMESPACE    NAME           STATUS     HEALTH   HOOK  MESSAGE
       Deployment  scaling-app  web-frontend   OutOfSync  Healthy        

$ argocd app diff scaling-app
===== apps/Deployment scaling-app/web-frontend ======
  spec:
-   replicas: 3
+   replicas: 5
    selector:
      matchLabels:
        app: web-frontend

$ kubectl get hpa -n scaling-app
NAME           REFERENCE                 TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
web-frontend   Deployment/web-frontend   45%/70%   2         10        5          1h

$ kubectl get application scaling-app -n argocd -o jsonpath='{.spec.ignoreDifferences}' | jq
[
  {
    "group": "apps",
    "kind": "Deployment",
    "jsonPointers": [
      "/spec/replicas"
    ]
  }
]

$ argocd app get scaling-app --output json | jq '.status.sync.status'
"OutOfSync"

$ kubectl get application scaling-app -n argocd -o jsonpath='{.status.conditions[*].message}'
"Failed to compare desired state: error normalizing resource: unable to apply ignore differences: invalid jsonPointer: /spec/replicas"
```

## Your Task

1. Identify why `ignoreDifferences` is not working
2. Find ALL configuration bugs (there are 4)
3. Fix the Application, ConfigMap, and Deployment to resolve the HPA conflict

## Files

- `application.yaml` — ArgoCD Application with broken `ignoreDifferences`
- `deployment.yaml` — The managed Deployment manifest
- `hpa.yaml` — HPA that conflicts with ArgoCD's desired state
- `argocd-cm-diffing.yaml` — ConfigMap patch for global diff customization
- `deploy.sh` / `cleanup.sh` — Lab lifecycle scripts

## Hints

<details>
<summary>Hint 1</summary>
The `jsonPointers` field in `ignoreDifferences` uses RFC 6901 JSON Pointer syntax. A common mistake is using `/spec/replicas` (correct for a direct field) vs wrong escaping. But the real issue might be that `ignoreDifferences` at the Application level doesn't automatically work with Server-Side Apply — you may need `managedFieldsManagers` configuration or need to use `jqPathExpressions` instead.
</details>

<details>
<summary>Hint 2</summary>
When using `jqPathExpressions`, the syntax is jq path expressions, not JSON Pointers. The correct jq path for replicas is `.spec.replicas` (not `/spec/replicas`). Also, jq path expressions need proper escaping in YAML — a dot-path in jq might need quoting.
</details>

<details>
<summary>Hint 3</summary>
ArgoCD 2.5+ supports Server-Side Apply (SSA) which properly handles field ownership conflicts. To enable it, you need `syncOptions: ["ServerSideApply=true"]` in the Application spec. Without SSA enabled, ArgoCD will always detect replicas drift because it performs a full-object comparison rather than respecting field managers. Check if SSA is enabled and if the `RespectIgnoreDifferences` sync option is also needed for normalization.
</details>

## Useful Commands

```bash
# Check Application sync status and conditions
argocd app get scaling-app
argocd app get scaling-app --output json | jq '.status.conditions'

# View the diff ArgoCD detects
argocd app diff scaling-app

# Check ignoreDifferences configuration
kubectl get application scaling-app -n argocd -o jsonpath='{.spec.ignoreDifferences}' | jq

# Check if Server-Side Apply is enabled
kubectl get application scaling-app -n argocd -o jsonpath='{.spec.syncPolicy.syncOptions}'

# View managed fields on the Deployment
kubectl get deployment web-frontend -n scaling-app -o json | jq '.metadata.managedFields'
kubectl get deployment web-frontend -n scaling-app -o json | jq '.metadata.managedFields[] | select(.manager | contains("argocd")) | .fieldsV1'

# Check HPA targets and replicas
kubectl get hpa web-frontend -n scaling-app -o yaml
kubectl describe hpa web-frontend -n scaling-app

# Check global ignore differences in argocd-cm
kubectl get cm argocd-cm -n argocd -o yaml | grep -A 20 "resource.compareoptions"
kubectl get cm argocd-cm -n argocd -o yaml | grep -A 20 "resource.customizations.ignoreDifferences"

# Force refresh to re-evaluate
argocd app get scaling-app --refresh

# Check ArgoCD resource comparison logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=100 | grep -i "ignore\|diff\|replicas"

# Test jqPathExpression evaluation
argocd admin settings resource-overrides ignore-differences ./deployment.yaml --argocd-cm-path argocd-cm-diffing.yaml
```

## What You'll Learn

- ArgoCD ignoreDifferences configuration (jsonPointers vs jqPathExpressions)
- Server-Side Apply field ownership and manager conflicts
- JSON Pointer (RFC 6901) syntax vs jq path expression syntax
- Global vs per-Application diff customization
- Proper HPA + ArgoCD coexistence patterns
- `RespectIgnoreDifferences` normalization for self-heal scenarios
