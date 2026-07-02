## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (applies broken Application manifest)
2. Check ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8443:443`
3. Open https://localhost:8443 (admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
4. See the app status (OutOfSync/Degraded/Error)
5. Debug: `argocd app get <app-name>`, check events
6. Fix the YAML, re-sync, verify. Check `solution.md` if stuck

---

# Lab 15: Multi-Source Application — Helm Values from Separate Repo Fails

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your team has adopted ArgoCD's multi-source Application feature to separate Helm chart code from environment-specific values. The architecture:

- **Source 1**: Helm chart from an OCI registry (chart repo)
- **Source 2**: Values files from a separate Git repository

The Application uses the `$values` reference syntax to tell the Helm chart source where to find values files from the other source. However, the sync fails with multiple errors related to source referencing, chart resolution, and values path mapping.

## Observed Behavior

```
$ argocd app get multi-source-app
Name:               argocd/multi-source-app
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          platform
Sync Status:        Unknown
Health Status:      Missing
Conditions:
- Type: ComparisonError
  Message: rpc error: code = Unknown desc = failed to generate manifests:
    error resolving source reference '$values': no source with ref 'values' found
- Type: ComparisonError  
  Message: rpc error: code = Unknown desc = failed to load Helm chart:
    chart "platform-service" version "2.x.x" not found in repository

$ argocd app manifests multi-source-app --source=live
FATA[0001] rpc error: code = Unknown desc = failed to generate manifests

$ kubectl get application multi-source-app -n argocd -o jsonpath='{.spec.sources}' | jq
[
  {
    "repoURL": "https://charts.example.com",
    "chart": "platform-service",
    "targetRevision": "2.x.x",
    "helm": {
      "valueFiles": [
        "$values/environments/production/values.yaml",
        "$values/environments/production/secrets.yaml"
      ]
    }
  },
  {
    "repoURL": "https://git.example.com/platform/helm-values.git",
    "targetRevision": "release-v2.0",
    "ref": "valuesRef"
  }
]

$ argocd app history multi-source-app
ID  DATE  REVISION
(no history — app never synced successfully)

$ argocd repo list
TYPE  NAME                              REPO                                         INSECURE  OCI    LFS    CREDS  STATUS
helm  example-charts                    https://charts.example.com                   false     false  false  false  Successful
git   platform-values                   https://git.example.com/platform/helm-values.git  false  false  false  true   Successful
```

## Your Task

1. Identify why the multi-source Application fails to generate manifests
2. Find ALL bugs in the configuration (there are 4)
3. Fix the Application spec to properly resolve chart + values from separate sources

## Files

- `application.yaml` — Multi-source Application spec with broken source references
- `helm-chart/` — Local Helm chart structure (representing what's in the chart repo)
- `values-repo/` — Git repository structure with environment-specific values
- `deploy.sh` / `cleanup.sh` — Lab lifecycle scripts

## Hints

<details>
<summary>Hint 1</summary>
The `ref` field on a source and the `$ref` placeholder in `valueFiles` must match exactly. If the source defines `ref: valuesRef` but the valueFiles use `$values/...`, the reference resolution fails. The prefix must be `$valuesRef` (matching the ref name), not `$values`.
</details>

<details>
<summary>Hint 2</summary>
Helm chart version constraints like `2.x.x` are NOT valid semver range syntax. Valid ranges include: `2.0.0`, `~2.0`, `>=2.0.0 <3.0.0`, `^2.0.0`, or `2.*`. The `x` placeholder is not recognized by the Helm version resolver used by ArgoCD.
</details>

<details>
<summary>Hint 3</summary>
When `targetRevision` references a branch (like `release-v2.0`) but the actual Git repo uses tags (`v2.0.0`) or a different branch naming convention (`release/v2.0`), the source will fail to resolve. Check whether the values repo uses branches, tags, or the exact ref name matches what exists in the remote.
</details>

## Useful Commands

```bash
# Check Application status and conditions
argocd app get multi-source-app
argocd app get multi-source-app --output json | jq '.status.conditions'

# View the multi-source spec
kubectl get application multi-source-app -n argocd -o yaml

# Check source references
kubectl get application multi-source-app -n argocd -o jsonpath='{.spec.sources}' | jq

# Verify repository connectivity
argocd repo list
argocd repo get https://charts.example.com
argocd repo get https://git.example.com/platform/helm-values.git

# List available chart versions
argocd repo chart-versions https://charts.example.com --chart platform-service

# Test source resolution
argocd app manifests multi-source-app --source=live

# Check what the values repo has
argocd app manifests multi-source-app --source=0
argocd app manifests multi-source-app --source=1

# Verify Helm values resolution
argocd app parameters multi-source-app

# Check ArgoCD application controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=100 | grep -i "multi-source\|values\|chart"

# Debug ref resolution
kubectl get application multi-source-app -n argocd -o jsonpath='{.spec.sources[1].ref}'

# Inspect chart index for available versions
helm repo add example https://charts.example.com 2>/dev/null && helm search repo example/platform-service --versions
```

## What You'll Learn

- ArgoCD multi-source Application architecture and `ref` field semantics
- `$ref` placeholder syntax in `valueFiles` for cross-source references
- Helm chart version constraint syntax vs semver ranges
- Git targetRevision resolution (branches vs tags vs commits)
- Multi-source manifest generation pipeline and error diagnosis
- Proper separation of chart code from environment configuration
