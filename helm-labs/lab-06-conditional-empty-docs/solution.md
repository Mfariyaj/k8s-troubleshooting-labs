# Lab 06 - Conditional Templates Produce Empty YAML Documents

## Root Cause

When conditional blocks (`{{ if }}`) evaluate to false, they leave behind empty YAML
documents (just `---` separators with no content). Kubernetes rejects these empty documents.
The fix is to use `{{- if }}` with proper whitespace control and ensure the YAML document
separator is inside the conditional block.

## Symptoms

- `helm template` produces output with empty `---` documents
- `helm install` fails with "unable to decode empty YAML document"
- Kubernetes API returns "resource has no kind" errors

## Fix Steps

1. Open the conditional templates
2. Add `{{-` (with dash) for whitespace trimming
3. Move the `---` document separator inside the `if` block
4. Ensure `{{- end }}` trims trailing whitespace

## Corrected Template

Before (broken):
```yaml
---
{{ if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "mychart.fullname" . }}
spec:
  rules:
    - host: {{ .Values.ingress.host }}
{{ end }}
```

After (fixed):
```yaml
{{- if .Values.ingress.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "mychart.fullname" . }}
spec:
  rules:
    - host: {{ .Values.ingress.host }}
{{- end }}
```

## Verification

```bash
# Template with feature disabled - should produce no empty docs
helm template myapp ./mychart --set ingress.enabled=false | grep -c "^---"

# Template with feature enabled - should produce valid YAML
helm template myapp ./mychart --set ingress.enabled=true | kubectl apply --dry-run=client -f -

# Lint the chart
helm lint ./mychart
```

## Key Takeaways

- Use `{{-` to trim whitespace/newlines before the directive
- Use `-}}` to trim whitespace/newlines after the directive
- Place `---` separator inside the `if` block, not outside
- Empty YAML documents are invalid and will be rejected
