## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 13: Subchart Global Values Not Propagating

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your microservices platform uses a parent Helm chart with multiple subcharts. Global values (image registry, pull secrets, environment) should propagate from the parent to all subcharts. After a chart refactoring to add aliases and import-values, the global values are either not reaching the subcharts, being overridden, or the subcharts aren't rendering at all.

## What You'll Observe

```
$ helm dependency build ./parentchart
Error: found in Chart.yaml, but missing in charts/ directory: subchart-frontend

$ # After investigating dependency naming:
$ helm template myrelease ./parentchart
Error: template: parentchart/charts/subchart-a/templates/deployment.yaml:25:26: 
  executing "parentchart/charts/subchart-a/templates/deployment.yaml" at <.Values.imageRegistry>: 
  nil pointer evaluating interface {}.imageRegistry

$ # After fixing template reference:
$ helm template myrelease ./parentchart | grep "image:"
  image: "docker.io/myapp/backend:latest"
  # Expected: registry.example.com/myapp/backend:latest

$ # Subchart uses its own global.imageRegistry (docker.io) instead of parent's (registry.example.com)!

$ helm template myrelease ./parentchart | grep "ENVIRONMENT" -A1
  value: development
  # Expected: production (from parent global)

$ # Subchart 'backend' has condition 'subchart-a.enabled' but values uses 'backend.enabled'
$ helm template myrelease ./parentchart --set subchart-a.enabled=false
  # Backend still renders! Condition key doesn't match.
```

## Your Task

Fix all issues so that:
1. Dependencies resolve correctly (names match chart directories)
2. Parent's `global.imageRegistry` reaches all subcharts
3. Subchart templates reference globals correctly (`.Values.global.X`)
4. Conditions work properly (can disable subcharts)
5. Aliases and import-values function as expected

## Hints

<details>
<summary>Hint 1</summary>
When you define an `alias` in Chart.yaml dependencies, the values for that subchart must be nested under the alias name in values.yaml, not the original chart name. But the `condition` key should also reference the alias. Check if `condition: subchart-a.enabled` is looking for a value under `subchart-a:` or `backend:` in the parent values.
</details>

<details>
<summary>Hint 2</summary>
If a subchart's `values.yaml` defines a `global:` block, it provides defaults that can be overridden by the parent. However, during `helm template`, subchart local defaults are merged first, then parent globals overlay. If the subchart template uses `.Values.imageRegistry` (without `.global`), it's reading from the subchart's non-global scope which doesn't inherit the parent's `global.imageRegistry`. The template must use `.Values.global.imageRegistry`.
</details>

<details>
<summary>Hint 3</summary>
For `import-values`, the subchart must define an `exports` key at the top level of its values.yaml — the format is `exports.<key>`. Check if subchart-a uses `exports.config` or a different structure like `exported.config`. Also, the dependency name in Chart.yaml must match the actual chart name in the charts/ directory; if it says `subchart-frontend` but the directory contains chart named `subchart-b`, dependency resolution fails.
</details>

## Commands to Help Diagnose

```bash
# Build dependencies
helm dependency build ./parentchart
helm dependency list ./parentchart

# Template and inspect output
helm template myrelease ./parentchart
helm template myrelease ./parentchart --debug

# Check specific subchart rendering
helm template myrelease ./parentchart -s charts/subchart-a/templates/deployment.yaml

# Inspect effective values for subcharts
helm template myrelease ./parentchart --show-only charts/subchart-a/templates/deployment.yaml --debug

# Check what values each subchart receives
helm template myrelease ./parentchart --set global.imageRegistry=TESTREGISTRY | grep TESTREGISTRY

# Verify conditions work
helm template myrelease ./parentchart --set backend.enabled=false
helm template myrelease ./parentchart --set subchart-a.enabled=false

# List what's in charts/ directory
ls -la parentchart/charts/
cat parentchart/charts/subchart-a/Chart.yaml

# Inspect Chart.yaml dependencies
cat parentchart/Chart.yaml

# Debug import-values
helm template myrelease ./parentchart --debug 2>&1 | head -50

# Check values merge order
helm show values ./parentchart/charts/subchart-a
helm show values ./parentchart
```

## What You'll Learn

- How Helm global values propagate to subcharts
- The difference between `.Values.X` and `.Values.global.X` in subcharts
- How aliases affect value scoping and condition keys
- The `import-values` mechanism and `exports` convention
- Dependency resolution with `file://` repositories
- How subchart values.yaml defaults interact with parent globals
