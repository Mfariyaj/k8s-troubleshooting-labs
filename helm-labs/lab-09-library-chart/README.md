## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 09: Library Chart Template Reference Error

## Difficulty: ⭐⭐⭐ Hard

## Scenario

A developer created a library chart (`mylib`) with reusable templates including `mylib.deployment` and `mylib.labels`. Their application chart (`mychart`) depends on this library chart and tries to use its templates. However, the application chart references the template with the WRONG name — `mylib.deploy` instead of `mylib.deployment`.

Your task: Fix the template reference so the application chart correctly uses the library chart's templates.

## Error Output

```
$ helm dependency update ./mychart
Saving 1 charts
Deleting outdated charts

$ helm template myrelease ./mychart --debug
Error: template: mychart/templates/deployment.yaml:5:12: executing "mychart/templates/deployment.yaml" at <include "mylib.deploy" .>: template "mylib.deploy" not defined
```

## Hints

1. Look at the library chart's `_helpers.tpl` file to see the actual template names defined with `{{ define "..." }}`.
2. The application chart uses `{{ include "mylib.deploy" . }}` but the library defines `{{ define "mylib.deployment" }}`.
3. Template names must match exactly — there's no fuzzy matching or aliasing in Helm templates.

## Commands

```bash
# Update dependencies first
helm dependency update ./mychart

# Show the error
helm template myrelease ./mychart --debug

# Check what templates the library defines
grep 'define "' mylib/templates/_helpers.tpl

# After fixing, verify
helm template myrelease ./mychart --debug
```

## Root Cause

The application chart's `deployment.yaml` calls:
```
{{ include "mylib.deploy" . }}
```

But the library chart defines the template as:
```
{{ define "mylib.deployment" }}
```

The template name `mylib.deploy` does not exist.

## Fix

Change the include reference in `mychart/templates/deployment.yaml`:

```yaml
{{ include "mylib.deployment" . }}
```
