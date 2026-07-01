# Lab 06: Conditional Rendering Produces Empty YAML Documents

## Difficulty: ⭐⭐ Medium

## Scenario

A developer has a ServiceMonitor template wrapped in an `if` conditional. When `monitoring.enabled` is `false`, the template file still produces an empty YAML document separator (`---`) because the separator is placed outside the `if` block. This empty document causes errors in some Kubernetes tools and `kubectl apply` pipelines that reject empty resources.

Your task: Fix the template so that when the condition is false, NO output is produced at all — not even `---`.

## Error Output

```
$ helm template myrelease ./mychart --debug
---
# Source: mychart/templates/servicemonitor.yaml
---

$ helm template myrelease ./mychart | kubectl apply --dry-run=client -f -
error: error validating "STDIN": error validating data: invalid empty YAML document; if you choose to ignore these errors, turn validation off with --validate=false
```

## Hints

1. The `---` YAML document separator is placed BEFORE the `{{- if }}` block. When the condition is false, only `---` remains in the output.
2. Move the `---` separator inside the `if` block, or remove it entirely (Helm adds separators automatically between sources).
3. The correct pattern is: `{{- if .Values.monitoring.enabled }}` at the very first line of the file with no content before it.

## Commands

```bash
# Show the empty document issue
helm template myrelease ./mychart --debug

# Pipe to kubectl to see the validation error
helm template myrelease ./mychart | kubectl apply --dry-run=client -f -

# After fixing, verify no empty documents
helm template myrelease ./mychart --debug | grep -c "^---"
```

## Root Cause

The `---` YAML document separator is on line 1, BEFORE the `{{- if }}` block. When `monitoring.enabled` is `false`, the `if` block produces no output, but the `---` separator remains, creating an empty YAML document.

## Fix

Remove the leading `---` or place everything inside the conditional:

```yaml
{{- if .Values.monitoring.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ .Release.Name }}-monitor
  labels:
    app: {{ .Release.Name }}
spec:
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  endpoints:
    - port: metrics
      interval: {{ .Values.monitoring.interval }}
      path: {{ .Values.monitoring.path }}
{{- end }}
```
