## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 14: Helm Release History Overflow

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your CI/CD pipeline deploys to production on every merge to main — sometimes 20+ times per day. Over months, one particular Helm release has accumulated 55+ revisions stored as Kubernetes secrets. Now `helm upgrade` is failing with "etcd request too large" errors, `helm rollback` points to a corrupted revision, and the namespace is bloated with hundreds of megabytes of release metadata.

## What You'll Observe

```
$ helm upgrade history-overflow ./mychart --namespace lab14-history --set config.version=v56
Error: UPGRADE FAILED: create: failed to create: etcdserver: request is too large

$ # Check how many release secrets exist:
$ kubectl get secrets -n lab14-history -l owner=helm | wc -l
56

$ # Each secret stores gzipped base64-encoded release manifest
$ kubectl get secret sh.helm.release.v1.history-overflow.v50 -n lab14-history -o jsonpath='{.data.release}' | wc -c
1048576  # ~1MB per release secret

$ # Try rollback to a known-good revision:
$ helm rollback history-overflow 25 --namespace lab14-history
Error: ROLLBACK FAILED: release "history-overflow" revision 25: could not decode release: 
  illegal base64 data at input byte 0

$ # Check release history
$ helm history history-overflow --namespace lab14-history
REVISION  STATUS      CHART         APP VERSION  DESCRIPTION
1         superseded  mychart-0.1.0 1.0.0        Install complete
2         superseded  mychart-0.1.0 1.0.0        Upgrade complete
...
25        superseded  mychart-0.1.0 1.0.0        corrupted
...
55        deployed    mychart-0.1.0 1.0.0        Upgrade complete

$ # Investigate the corrupted revision
$ kubectl get secret sh.helm.release.v1.history-overflow.v25 -n lab14-history -o yaml | grep modifiedAt
    modifiedAt: corrupted
```

## Your Task

Fix all issues so that:
1. Remove corrupted release secrets
2. Reduce release history to a manageable size
3. Future upgrades use `--history-max` to prevent recurrence
4. Successfully upgrade to the next version
5. Verify the release is healthy after cleanup

## Hints

<details>
<summary>Hint 1</summary>
Helm stores each release revision as a Kubernetes secret named `sh.helm.release.v1.<release-name>.v<revision>`. When too many accumulate, the total size of list responses can exceed etcd's default 1.5MB request limit. You can manually delete old secrets to reduce the count, but you must preserve the latest deployed revision and not break the revision chain Helm expects.
</details>

<details>
<summary>Hint 2</summary>
The `--history-max` flag tells Helm to keep only N revisions. Setting `helm upgrade --history-max 10` will automatically prune old revisions on each upgrade. But first you need to get the release to a state where upgrade can succeed — which means manually deleting some old secrets. Target secrets with status `superseded` that you don't need for rollback.
</details>

<details>
<summary>Hint 3</summary>
The corrupted revision (v25) has invalid data in its secret. You can identify it by checking the `modifiedAt` label or trying to decode its content. Delete it with `kubectl delete secret sh.helm.release.v1.history-overflow.v25 -n lab14-history`. After pruning enough old secrets, retry the upgrade with `--history-max 10`. If Helm still complains about the revision chain, you may need to delete secrets in a specific order or patch the remaining ones.
</details>

## Commands to Help Diagnose

```bash
# Count release secrets
kubectl get secrets -n lab14-history -l owner=helm | wc -l
kubectl get secrets -n lab14-history -l owner=helm,name=history-overflow --sort-by=.metadata.creationTimestamp

# Check total size of secrets in namespace
kubectl get secrets -n lab14-history -o json | wc -c

# Inspect a specific revision's metadata
kubectl get secret sh.helm.release.v1.history-overflow.v25 -n lab14-history -o yaml

# Check labels on release secrets
kubectl get secrets -n lab14-history -l owner=helm --show-labels

# View release history
helm history history-overflow --namespace lab14-history
helm history history-overflow --namespace lab14-history --max 10

# Try decoding a release secret
kubectl get secret sh.helm.release.v1.history-overflow.v50 -n lab14-history \
  -o jsonpath='{.data.release}' | base64 -d | gzip -d | head -100

# Delete old revisions manually (be careful!)
kubectl delete secret sh.helm.release.v1.history-overflow.v1 -n lab14-history

# Bulk delete old revisions
for i in $(seq 1 40); do
  kubectl delete secret "sh.helm.release.v1.history-overflow.v${i}" -n lab14-history 2>/dev/null
done

# Retry upgrade with history limit
helm upgrade history-overflow ./mychart --namespace lab14-history \
  --history-max 10 --set config.version=v56

# Check etcd metrics (if accessible)
kubectl get --raw /metrics | grep etcd_db_total_size

# Verify final state
helm status history-overflow --namespace lab14-history
helm history history-overflow --namespace lab14-history
```

## What You'll Learn

- How Helm stores release state in Kubernetes secrets
- The impact of unbounded release history on etcd
- Using `--history-max` to prevent history overflow
- Safely cleaning up corrupted release revisions
- Understanding the Helm release revision chain
- etcd size limits and their impact on Helm operations
- Production best practices for CI/CD pipelines using Helm
