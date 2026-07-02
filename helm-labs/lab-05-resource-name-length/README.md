## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 05: Resource Name Length Exceeds 63 Characters

## Difficulty: ⭐⭐ Medium

## Scenario

A developer created a Helm chart with a very long chart name (`my-super-long-application-chart-name-that-exceeds-kubernetes-limits`). When combined with the release name in the template (`<release-name>-<chart-name>`), the resulting Kubernetes resource name exceeds the 63-character DNS label limit. This causes the deployment to be rejected by the Kubernetes API server.

Your task: Fix the chart so the generated resource names stay within the 63-character limit.

## Error Output

```
$ helm install my-production-release ./mychart --dry-run --debug
Error: INSTALLATION FAILED: Deployment.apps "my-production-release-my-super-long-application-chart-name-that-exceeds-kubernetes-limits" is invalid:
  metadata.name: Invalid value: "my-production-release-my-super-long-application-chart-name-that-exceeds-kubernetes-limits":
    must be no more than 63 characters

$ echo -n "my-production-release-my-super-long-application-chart-name-that-exceeds-kubernetes-limits" | wc -c
89
```

## Hints

1. Kubernetes resource names must conform to DNS label rules: max 63 characters, lowercase alphanumeric and hyphens only.
2. Use `fullnameOverride` in values.yaml to provide a short name, or use the `trunc 63` function in templates.
3. The standard Helm `_helpers.tpl` pattern uses `{{ include "mychart.fullname" . | trunc 63 | trimSuffix "-" }}` to enforce the limit.

## Commands

```bash
# Show the name length error
helm install my-production-release ./mychart --dry-run --debug

# Check the generated name length
helm template my-production-release ./mychart 2>&1 | grep "name:" | head -5

# After fixing, verify names are under 63 chars
helm template my-production-release ./mychart | grep "name:" | awk '{print length($2), $2}'
```

## Root Cause

The template generates resource names as `{{ .Release.Name }}-{{ .Chart.Name }}` without any truncation. With a long chart name and release name, the combined string exceeds 63 characters, violating Kubernetes DNS label limits.

## Fix

Option 1: Set `fullnameOverride` in values.yaml:
```yaml
fullnameOverride: "my-app"
```

Option 2: Add `trunc 63` to the template:
```yaml
metadata:
  name: {{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
```

Option 3: Use a shorter chart name in Chart.yaml:
```yaml
name: my-app
```
