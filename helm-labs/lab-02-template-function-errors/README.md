## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 02: Template Function Errors

## Difficulty: ⭐⭐ Medium

## Scenario

A developer created a Helm chart with a deployment template that uses `indent` instead of `nindent` for the resources block, causing incorrect YAML indentation. Additionally, inside a `range` loop, they reference `.Values.image.tag` which fails because the scope (`.`) changes inside `range` — they need to use `$` to access the root scope.

Your task: Fix the template rendering errors so `helm template` produces valid YAML.

## Error Output

```
$ helm template myrelease ./mychart --debug
Error: YAML parse error on mychart/templates/deployment.yaml: error converting YAML to JSON: yaml: line 32: mapping values are not allowed in this context

---
# Source: mychart/templates/deployment.yaml
...
          resources:
            limits:    # <-- Extra indentation from indent vs nindent
              cpu: 200m
              memory: 256Mi
            requests:
              cpu: 100m
              memory: 128Mi
          env:
            - name: LABEL_ENVIRONMENT
              value:                # <-- nil! .Values is not accessible inside range without $
            - name: LABEL_TEAM
              value:
            - name: LABEL_TIER
              value:
```

## Hints

1. `indent` adds indentation to ALL lines including the first. Since the piped content already starts at the correct position, you get double-indentation. Use `nindent` which adds a newline first, then indents consistently.
2. Inside a `range` block, the dot (`.`) is rebound to the current iteration element. To access `.Values`, use the root variable `$` (e.g., `$.Values.image.tag`).
3. The correct pattern is: `{{ toYaml .Values.resources | nindent 12 }}` and `{{ $.Values.image.tag }}` inside range blocks.

## Commands

```bash
# Show the template errors
helm template myrelease ./mychart --debug

# After fixing, verify clean output
helm template myrelease ./mychart --debug | kubectl apply --dry-run=client -f -
```

## Root Cause

Two issues:
1. `indent 12` on line 30 adds 12 spaces to every line including the first, but the `resources:` key already has the pipeline inline, causing malformed YAML.
2. Inside `range $key, $value := .Values.labels`, the dot scope is rebound. Referencing `.Values.image.tag` resolves to nil. Must use `$.Values.image.tag`.

## Fix

```yaml
# Fix 1: Change indent to nindent
          resources:
            {{- toYaml .Values.resources | nindent 12 }}

# Fix 2: Use $ for root scope inside range
            {{- range $key, $value := .Values.labels }}
            - name: LABEL_{{ $key | upper }}
              value: {{ $.Values.image.tag }}
            {{- end }}
```
