# Lab 02 - Template Function Errors

## Root Cause

The Helm templates have two common Go template mistakes:
1. Using `indent` instead of `nindent` - `indent` doesn't add a newline before indenting,
   causing YAML content to start on the same line as the key
2. Using `.Values` inside a `range` loop without `$` - inside `range`, the context (`.`)
   changes to the current item, so root values require `$.Values`

## Symptoms

- `helm template` produces invalid YAML
- Error: "mapping values are not allowed in this context"
- Values inside range loops resolve to empty or wrong values
- YAML indentation is broken

## Fix Steps

1. Replace `indent` with `nindent` where content needs to start on a new line
2. Use `$` (dollar sign) to access root context inside `range` blocks

## Corrected Templates

Before (broken):
```yaml
metadata:
  labels:
    {{- include "mychart.labels" . | indent 4 }}
spec:
  containers:
    {{- range .Values.containers }}
    - name: {{ .name }}
      image: {{ .Values.global.registry }}/{{ .image }}
    {{- end }}
```

After (fixed):
```yaml
metadata:
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
spec:
  containers:
    {{- range .Values.containers }}
    - name: {{ .name }}
      image: {{ $.Values.global.registry }}/{{ .image }}
    {{- end }}
```

## Verification

```bash
# Validate template renders valid YAML
helm template myapp ./mychart

# Lint the chart
helm lint ./mychart

# Install with dry-run to verify
helm install myapp ./mychart --dry-run --debug
```

## Key Takeaways

- `nindent N` = newline + indent N spaces (use after `|` or `|-`)
- `indent N` = indent without newline (use when content is already on new line)
- Inside `range`, use `$.Values` to access root scope
- Inside `range`, `.` refers to the current iteration item
