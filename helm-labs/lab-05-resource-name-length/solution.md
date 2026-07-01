# Lab 05 - Resource Name Length Exceeds 63 Characters

## Root Cause

Kubernetes resource names are limited to 63 characters (DNS label standard). The Helm
chart's fullname template concatenates release name + chart name without truncation,
producing names that exceed 63 characters and are rejected by the API server.

## Symptoms

- `helm install` fails with "must be no more than 63 characters"
- Invalid resource names in rendered YAML
- Kubernetes API rejects resources during apply

## Fix Steps

Option A: Use `fullnameOverride` in values to set a short explicit name
Option B: Fix the `_helpers.tpl` template to truncate to 63 characters

## Corrected Configuration

Option A - Use fullnameOverride in `values.yaml`:
```yaml
fullnameOverride: "myapp"
```

Option B - Fix `templates/_helpers.tpl`:
```yaml
{{- define "mychart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
```

## Verification

```bash
# Template and check name lengths
helm template my-very-long-release-name ./mychart | grep "name:" | awk '{print length($2), $2}'

# Verify no name exceeds 63 chars
helm template myapp ./mychart | grep "name:" | awk '{if(length($2)>63) print "TOO LONG:", $2}'

# Install successfully
helm install myapp ./mychart
kubectl get all -l app.kubernetes.io/instance=myapp
```

## Key Takeaways

- Kubernetes names are limited to 63 characters (DNS-1123 label)
- Always use `trunc 63 | trimSuffix "-"` in name templates
- `fullnameOverride` provides a simple escape hatch
- Test with long release names during chart development
