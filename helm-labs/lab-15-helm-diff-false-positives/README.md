## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 15: Helm Diff Plugin False Positives

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your GitOps pipeline runs `helm diff upgrade` before applying changes to verify what will be modified. However, the diff output shows changes on EVERY run, even when no chart values have been changed. The diffs show fields like `metadata.managedFields`, `metadata.annotations` (injected by admission controllers), `status` fields, and timestamp annotations that the server adds post-apply. This causes your pipeline to trigger unnecessary deployments and alerts.

## What You'll Observe

```
$ helm diff upgrade myapp ./mychart --namespace lab15-diff
default, myapp-mychart, Deployment (apps) has changed:
  # Source: mychart/templates/deployment.yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
+   annotations:
+     deployment.kubernetes.io/revision: "3"
+     kubectl.kubernetes.io/last-applied-configuration: |
+       {...entire manifest...}
    name: myapp-mychart
+   managedFields:
+   - apiVersion: apps/v1
+     fieldsType: FieldsV1
+     fieldsV1:
+       f:spec:
+         f:replicas: {}
+     manager: kube-controller-manager
+     operation: Update
+     time: "2024-12-15T10:00:00Z"
  spec:
    template:
      metadata:
+       annotations:
+         cni.projectcalico.org/podIPs: "10.244.1.15/32"
+         sidecar.istio.io/status: '{...injected...}'
    spec:
      containers:
        - name: mychart
+         resources:
+           limits:
+             cpu: 500m    # <-- VPA mutated this!
+           requests:
+             cpu: 250m

default, myapp-mychart, Service (v1) has changed:
+ status:
+   loadBalancer: {}
+   conditions: [...]

$ helm diff upgrade myapp ./mychart --namespace lab15-diff --normalize-manifests
Error: unknown flag: --normalize-manifests
# ^ helm-diff version too old for this flag

$ helm diff upgrade myapp ./mychart --namespace lab15-diff --three-way-merge
# Still shows changes because of server-side mutations
```

## Your Task

Fix all issues so that `helm diff` only shows actual changes you intend to make:
1. Eliminate false positives from managedFields
2. Filter out annotations added by admission controllers
3. Handle status fields correctly
4. Use the correct helm-diff version with proper flags
5. Understand three-way vs two-way diff behavior

## Hints

<details>
<summary>Hint 1</summary>
Helm-diff versions prior to 3.8.0 don't support `--normalize-manifests`. Check your version with `helm diff version`. Upgrade if needed. The `--normalize-manifests` flag strips managedFields and other server-added metadata. Alternatively, you can use `--suppress` to suppress specific change types.
</details>

<details>
<summary>Hint 2</summary>
The deployment template is missing annotations that admission controllers always add. If you know certain annotations will always be present (like from Istio, Calico, or VPA), you can either: (1) add them to your template so they don't show as diff, (2) use `--suppress-secrets` and field-specific suppression, or (3) use `helm diff upgrade --no-hooks --reset-values --three-way-merge` to let Helm's three-way merge handle server mutations.
</details>

<details>
<summary>Hint 3</summary>
The Service template renders as `type: ClusterIP` but the live object has `status.loadBalancer: {}` added by the service controller. Helm-diff's `--three-way-merge` flag compares against the last applied config (stored in the release secret) rather than the live object, which eliminates most server-side additions. But your template must not drift from what Helm actually applied. Check if there are webhook-injected fields that need to be accounted for in the chart itself.
</details>

## Commands to Help Diagnose

```bash
# Check helm-diff version
helm diff version
helm plugin list

# Update helm-diff to latest
helm plugin update diff

# Install specific version
helm plugin install https://github.com/databus23/helm-diff --version v3.9.4

# Basic diff (shows false positives)
helm diff upgrade myapp ./mychart --namespace lab15-diff

# Try normalize flag
helm diff upgrade myapp ./mychart --namespace lab15-diff --normalize-manifests

# Use three-way merge
helm diff upgrade myapp ./mychart --namespace lab15-diff --three-way-merge

# Suppress specific output
helm diff upgrade myapp ./mychart --namespace lab15-diff --suppress-secrets

# Show only summary
helm diff upgrade myapp ./mychart --namespace lab15-diff --output summary

# Compare live object vs rendered template
helm get manifest myapp --namespace lab15-diff > /tmp/current.yaml
helm template myapp ./mychart > /tmp/desired.yaml
diff /tmp/current.yaml /tmp/desired.yaml

# Check what's actually on the cluster
kubectl get deployment myapp-mychart -n lab15-diff -o yaml | head -50

# Inspect managedFields
kubectl get deployment myapp-mychart -n lab15-diff -o jsonpath='{.metadata.managedFields}' | python3 -m json.tool

# Check annotations added by controllers
kubectl get deployment myapp-mychart -n lab15-diff -o jsonpath='{.metadata.annotations}' | python3 -m json.tool

# Remove managedFields from live objects (temporary fix)
kubectl patch deployment myapp-mychart -n lab15-diff --type=json \
  -p='[{"op": "remove", "path": "/metadata/managedFields"}]'

# Check if VPA is mutating pods
kubectl get vpa -n lab15-diff
kubectl describe vpa myapp-vpa -n lab15-diff
```

## What You'll Learn

- How Kubernetes server-side field management works (managedFields)
- How admission controllers and mutating webhooks modify objects post-apply
- The difference between two-way and three-way merge in Helm
- How helm-diff compares rendered templates vs live cluster state
- Strategies for eliminating false positives in GitOps diff pipelines
- VPA/Istio/Calico interactions with Helm-managed resources
- Best practices for `helm diff` in CI/CD pipelines
