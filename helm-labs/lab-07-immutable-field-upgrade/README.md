## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 07: Immutable Field Upgrade Failure

## Difficulty: ⭐⭐⭐ Hard

## Scenario

A developer's Helm chart includes `{{ .Chart.AppVersion }}` and `{{ .Chart.Version }}` in the `selector.matchLabels` of a Deployment. The initial install works fine (v0.1.0). However, when they upgrade the chart to v0.2.0, the upgrade fails because Kubernetes does not allow changes to `spec.selector.matchLabels` after a Deployment is created — it's an immutable field.

Your task: Fix the Deployment template so that `selector.matchLabels` only contains labels that don't change between upgrades.

## Error Output

```
$ helm install myrelease ./mychart     # Works fine (first install)
NAME: myrelease
STATUS: deployed

$ # Developer bumps Chart.yaml version to 0.2.0 and appVersion to "2.0.0"
$ helm upgrade myrelease ./mychart
Error: UPGRADE FAILED: cannot patch "myrelease-mychart" with kind Deployment:
  Deployment.apps "myrelease-mychart" is invalid:
  spec.selector: Invalid value: v1.LabelSelector{
    MatchLabels: map[string]string{
      "app.kubernetes.io/instance":"myrelease",
      "app.kubernetes.io/name":"mychart",
      "app.kubernetes.io/version":"2.0.0",       <-- was "1.0.0"
      "helm.sh/chart":"mychart-0.2.0"            <-- was "mychart-0.1.0"
    }
  }: field is immutable
```

## Hints

1. `spec.selector.matchLabels` is immutable after creation — you cannot change it on upgrade.
2. Never include values that change between chart versions (like `Chart.Version`, `Chart.AppVersion`) in `selector.matchLabels`.
3. Version labels are fine in `metadata.labels` and `template.metadata.labels` (informational), but must NOT be in `selector.matchLabels`.

## Commands

```bash
# Show the template output with version in selectors
helm template myrelease ./mychart --debug

# On a live cluster, demonstrate the failure
helm install myrelease ./mychart
# Edit Chart.yaml to bump version
helm upgrade myrelease ./mychart
```

## Root Cause

The template includes mutable/version-dependent labels in `spec.selector.matchLabels`:
- `app.kubernetes.io/version: {{ .Chart.AppVersion }}`
- `helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}`

These change on every chart version bump, but `selector.matchLabels` is immutable after Deployment creation.

## Fix

Only include stable, non-changing labels in `selector.matchLabels`:

```yaml
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: mychart
      app.kubernetes.io/instance: {{ .Release.Name }}
```

Keep version labels in `metadata.labels` and `template.metadata.labels` for informational purposes only.
