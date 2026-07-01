# Lab 15: Flux CD GitOps Reconciliation Stuck — Ready=False, Source Not Updating

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your platform team recently adopted Flux CD for GitOps-driven deployments. After a repository restructuring (moving manifests from `/deploy` to `/k8s/overlays/production`), the entire reconciliation pipeline broke. The Kustomization shows `Ready=False`, the HelmRelease can't install the monitoring stack, and all downstream resources are stuck because of dependency chains.

The team pushed a critical security fix 45 minutes ago but it hasn't been deployed because:
1. The GitRepository source checks every 1 hour (too slow)
2. The Kustomization points to a path that no longer exists
3. The HelmRelease can't find its values secret
4. The dependency chain has a namespace mismatch
5. All downstream Kustomizations are blocked by the broken upstream

## Error Output

```
$ flux get sources git -n flux-system
NAME        REVISION    SUSPENDED  READY  MESSAGE
infra-repo  main@sha1:abc123  False  True   stored artifact for revision 'main@sha1:abc123'
                                            Last reconciled: 47m ago
```

```
$ flux get kustomizations -n flux-system
NAME              REVISION  SUSPENDED  READY   MESSAGE
app-production              False      False   kustomization path not found:
                                               stat /tmp/kustomization-xyz/deploy:
                                               no such file or directory
app-monitoring              False      False   dependency 'flux-system/app-production'
                                               is not ready
```

```
$ flux get helmreleases -n flux-system
NAME              REVISION  SUSPENDED  READY  MESSAGE
monitoring-stack            False      False  HelmChart 'flux-system/flux-system-monitoring-stack'
                                              is not ready: chart "kube-prometheus-stack"
                                              not found in "prometheus-community" repository

$ kubectl describe helmrelease monitoring-stack -n flux-system
...
Status:
  Conditions:
    - Type: Ready
      Status: "False"
      Reason: ArtifactFailed
      Message: |
        HelmChart 'flux-system/flux-system-monitoring-stack' is not ready
        source "prometheus-community" not found in namespace "flux-system"
    - Type: Ready
      Status: "False"
      Reason: ValuesError
      Message: |
        values from Secret 'flux-system/monitoring-values' not found:
        Secret "monitoring-values" not found
```

```
$ kubectl describe kustomization app-production -n flux-system
...
Status:
  Conditions:
    - Type: Ready
      Status: "False"
      Reason: ArtifactFailed
      Message: "Source 'GitRepository/flux-system/infra-repo' is not ready"
    - Type: Ready
      Status: "False"
      Reason: BuildFailed
      Message: "kustomization path not found"
    - Type: Healthy
      Status: "False"
      Reason: HealthCheckFailed
      Message: "timeout waiting for: [Deployment/production/app-server,
                StatefulSet/production/app-database status: 'InProgress']"
Events:
  Warning  DependencyNotReady  2m   dependency 'default/monitoring-stack' is not ready:
                                     HelmRelease not found in namespace 'default'
```

## Your Task

Fix the entire Flux CD reconciliation chain:
1. Reduce GitRepository polling interval for faster change detection
2. Fix the Kustomization path to match the new repo structure
3. Create the missing HelmRepository and values Secret (or make it optional)
4. Fix the `dependsOn` namespace reference
5. Increase health check timeout to accommodate slow rollouts

## Hints

<details>
<summary>Hint 1</summary>
The GitRepository `interval: 1h` means changes are detected up to 60 minutes late. Set it to `interval: 5m` or `interval: 1m`. For even faster detection, configure webhooks with a Flux `Receiver`. The Kustomization `path: ./deploy` should be `path: ./k8s/overlays/production` to match the new repo structure.
</details>

<details>
<summary>Hint 2</summary>
The Kustomization has `dependsOn: [{name: monitoring-stack, namespace: default}]` but the HelmRelease is in `flux-system` namespace. Change to `namespace: flux-system`. Also, the `timeout: 2m` is too short — increase it to `timeout: 10m` to allow for database migrations and rolling updates.
</details>

<details>
<summary>Hint 3</summary>
The HelmRelease references `valuesFrom` with `optional: false` for a Secret that doesn't exist. Either create the Secret, or set `optional: true` to allow the release to proceed without it. Also, create the missing HelmRepository resource for `prometheus-community`. The commented-out resource at the bottom of helmrelease.yaml shows what's needed.
</details>

## Useful Commands

```bash
# Examine all Flux resources
cat flux-system/gitrepository.yaml
cat flux-system/kustomization.yaml
cat flux-system/helmrelease.yaml

# Check Flux source status
flux get sources git -n flux-system
flux get sources helm -n flux-system
flux get sources chart -n flux-system

# Check kustomization status
flux get kustomizations -n flux-system -A

# Check helm releases
flux get helmreleases -n flux-system

# Force reconciliation (bypass interval)
flux reconcile source git infra-repo -n flux-system
flux reconcile kustomization app-production -n flux-system

# Get detailed status
kubectl describe gitrepository infra-repo -n flux-system
kubectl describe kustomization app-production -n flux-system
kubectl describe helmrelease monitoring-stack -n flux-system

# Check Flux logs
flux logs --level=error
kubectl logs -n flux-system deployment/source-controller
kubectl logs -n flux-system deployment/kustomize-controller
kubectl logs -n flux-system deployment/helm-controller

# List all Flux resources with status
flux get all -n flux-system

# Check for missing resources
kubectl get helmrepository -n flux-system
kubectl get secret monitoring-values -n flux-system

# Trace dependency chain
flux tree kustomization app-production -n flux-system

# Check events
kubectl get events -n flux-system --sort-by='.lastTimestamp'

# Suspend and resume (useful for debugging)
flux suspend kustomization app-production -n flux-system
flux resume kustomization app-production -n flux-system
```

## What You'll Learn

- Flux CD reconciliation loop and source management
- GitRepository polling intervals and webhook receivers
- Kustomization path resolution and dependency chains
- HelmRelease valuesFrom with optional/required secrets
- Cross-namespace dependency references
- Cascading failures in GitOps dependency graphs
- Health check timeouts for slow deployments
- Debugging Flux controllers and reconciliation status
