# Lab 07 - Immutable Field Upgrade Failure

## Root Cause

The chart includes `chart version` in Deployment selector labels (e.g.,
`app.kubernetes.io/version` or `helm.sh/chart`). Kubernetes selector labels are
immutable after creation. When the chart version changes on upgrade, Helm tries to
update the selector, which Kubernetes rejects.

## Symptoms

- `helm upgrade` fails with "field is immutable" error
- Error specifically mentions `.spec.selector.matchLabels`
- First install works; subsequent upgrades always fail

## Fix Steps

1. Open `templates/_helpers.tpl`
2. Remove chart version from the `selectorLabels` template
3. Keep version only in non-selector labels (metadata labels are mutable)

## Corrected Configuration

`templates/_helpers.tpl`:
```yaml
{{- define "mychart.labels" -}}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "mychart.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels - MUST NOT include version or chart */}}
{{- define "mychart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

In Deployment template:
```yaml
spec:
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "mychart.labels" . | nindent 8 }}
```

## Verification

```bash
# Install initial version
helm install myapp ./mychart

# Bump chart version in Chart.yaml, then upgrade
helm upgrade myapp ./mychart

# Verify upgrade succeeds
helm history myapp
kubectl get deployment -l app.kubernetes.io/instance=myapp
```

## Key Takeaways

- Never include mutable values (version, chart) in selector labels
- Selector labels are immutable after resource creation
- Use separate helper templates for selector vs metadata labels
- Standard Helm charts use only `name` and `instance` as selector labels
