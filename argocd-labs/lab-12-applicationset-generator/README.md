## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (applies broken Application manifest)
2. Check ArgoCD UI: `kubectl port-forward svc/argocd-server -n argocd 8443:443`
3. Open https://localhost:8443 (admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
4. See the app status (OutOfSync/Degraded/Error)
5. Debug: `argocd app get <app-name>`, check events
6. Fix the YAML, re-sync, verify. Check `solution.md` if stuck

---

# Lab 12: ApplicationSet Generator — Duplicates, Missing Apps, and Merge Conflicts

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your platform team uses an ApplicationSet to dynamically generate ArgoCD Applications for a multi-cluster, multi-environment setup. The ApplicationSet uses a **Matrix generator** that combines a Git directory generator with a Cluster generator to produce one Application per (service × cluster) combination.

Expected behavior: 6 applications (3 services × 2 clusters)
Actual behavior: Either 0 applications generated, duplicate applications, or applications with wrong parameters overwritten by template merging.

The SRE team reports:
- Some clusters get the wrong service deployed
- The `staging` cluster gets `production` configuration
- ApplicationSet controller logs show gotemplate parse errors
- Some expected applications are completely missing

## Observed Behavior

```
$ kubectl get applicationsets -n argocd
NAME                    AGE
platform-services-set   5m

$ kubectl get applications -n argocd -l app.kubernetes.io/managed-by=applicationset-controller
No resources found in argocd namespace.

$ kubectl logs -n argocd -l app.kubernetes.io/name=argocd-applicationset-controller --tail=50
time="2024-01-15T14:30:00Z" level=error msg="error generating application" applicationset="argocd/platform-services-set" error="failed to execute go template: template: :1: function \"toUpper\" not defined"
time="2024-01-15T14:30:01Z" level=error msg="error generating params" applicationset="argocd/platform-services-set" generator="{Matrix:{Generators:[{Git:nil Cluster:...}]}}" error="no generator found for matrix element 0"
time="2024-01-15T14:30:01Z" level=warning msg="cluster generator: no clusters matched label selector" selector="environment in (production,staging)" applicationset="argocd/platform-services-set"

$ argocd appset get platform-services-set
Name:               platform-services-set
Namespace:          argocd
Strategy:           unset
Template:
  ...
Generators:
- Matrix:
    - Git: (error)
    - Cluster: (no matches)

$ kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=cluster
NAME                          TYPE     DATA   AGE
cluster-secret-prod-us-east   Opaque   3      10m
cluster-secret-staging-eu     Opaque   3      10m
```

## Your Task

1. Identify why the ApplicationSet produces 0 applications instead of 6
2. Find ALL bugs in the ApplicationSet configuration (there are 5)
3. Fix the configuration to correctly generate 3 services × 2 clusters = 6 Applications

## Files

- `applicationset.yaml` — Broken ApplicationSet with Matrix + Git + Cluster generators
- `git-repo-structure/` — Simulated Git repo directory structure with service configs
- `cluster-secrets/` — Kubernetes secrets representing registered clusters
- `deploy.sh` / `cleanup.sh` — Lab lifecycle scripts

## Hints

<details>
<summary>Hint 1</summary>
The Matrix generator expects `generators:` as an array with exactly 2 elements. Each element must be a valid generator type (`git`, `clusters`, `list`, etc). Check if the generator types are named correctly — it's `clusters` (plural) not `cluster` (singular) in the Matrix generator context.
</details>

<details>
<summary>Hint 2</summary>
Git directory generators use `directories:` with `path:` patterns. The path should match the actual directory structure in the repo. If your repo has `services/*/` but the generator specifies `apps/*/`, no directories will match. Also verify the `repoURL` points to the correct repository.
</details>

<details>
<summary>Hint 3</summary>
Cluster secrets must have the label `argocd.argoproj.io/secret-type: cluster` and the correct label that the cluster generator's `selector.matchLabels` references. Check if the label key on the secrets matches what the generator is filtering on — `env` vs `environment`, `tier` vs `stage`, etc.
</details>

## Useful Commands

```bash
# Check ApplicationSet status
kubectl get applicationsets -n argocd -o yaml
kubectl describe applicationset platform-services-set -n argocd

# View generated applications
kubectl get applications -n argocd -l app.kubernetes.io/managed-by=applicationset-controller

# Check ApplicationSet controller logs for errors
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-applicationset-controller --tail=200
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-applicationset-controller --tail=200 | grep -i error

# Inspect cluster secrets and their labels
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=cluster --show-labels
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=cluster -o yaml

# Dry-run ApplicationSet generation (requires argocd CLI 2.7+)
argocd appset generate platform-services-set --dry-run

# Verify Git directory structure expectations
ls -la git-repo-structure/

# Debug gotemplate rendering
kubectl get applicationset platform-services-set -n argocd -o jsonpath='{.spec.goTemplate}'

# Check if goTemplate is enabled
kubectl get applicationset platform-services-set -n argocd -o jsonpath='{.spec.goTemplate}'

# Validate YAML syntax
kubectl apply --dry-run=client -f applicationset.yaml

# Restart ApplicationSet controller after fixes
kubectl rollout restart deployment argocd-applicationset-controller -n argocd
```

## What You'll Learn

- ApplicationSet Matrix generator semantics and generator nesting
- Git directory generator path matching and parameter extraction
- Cluster generator label selectors and secret format requirements
- GoTemplate vs fasttemplate mode differences and function availability
- Template merge behavior and parameter precedence in ApplicationSets
