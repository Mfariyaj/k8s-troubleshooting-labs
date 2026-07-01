# Lab 09 - Library Chart Reference Mismatch

## Root Cause

The application chart references a template from the library chart using the wrong `define`
name. Library charts export named templates (e.g., `mylib.deployment`), and the consuming
chart must use the exact same name in its `{{ include }}` or `{{ template }}` call.

## Symptoms

- `helm template` fails with "template not defined" error
- Chart renders empty output for resources that should come from library
- Error: "can't evaluate field X in type interface {}"

## Fix Steps

1. Check the library chart's `templates/_helpers.tpl` for the exact `define` names
2. Update the application chart's template to use the matching name
3. Ensure the library chart is listed as a dependency and downloaded

## Corrected Configuration

In the library chart (`mylib/templates/_helpers.tpl`):
```yaml
{{- define "mylib.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mylib.fullname" . }}
  labels:
    {{- include "mylib.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "mylib.selectorLabels" . | nindent 6 }}
{{- end }}
```

In the application chart (`mychart/templates/deployment.yaml`):
```yaml
{{- include "mylib.deployment" . }}
```

Ensure `mychart/Chart.yaml` has the dependency:
```yaml
dependencies:
  - name: mylib
    version: "0.1.0"
    repository: "file://../mylib"
```

## Verification

```bash
# Update dependencies
cd mychart && helm dependency update

# Verify template renders
helm template myapp ./mychart

# Lint the chart
helm lint ./mychart

# Check that library templates are included
helm template myapp ./mychart | grep "kind: Deployment"
```

## Key Takeaways

- Library chart template names must match exactly in `include`/`template` calls
- Library charts (type: library) produce no output on their own
- Always run `helm dependency update` after adding library dependencies
- Use `file://` repository for local library chart development
