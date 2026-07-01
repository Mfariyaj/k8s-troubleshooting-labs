# Lab 13 - Subchart Global Values

## Root Cause

The parent-subchart communication has three issues:
1. Subchart templates use `.Values.imageRegistry` instead of `.Values.global.imageRegistry`
   (global values are accessed via the `global` key in subcharts)
2. The condition key in `Chart.yaml` doesn't match the values key for enabling/disabling
3. The subchart alias in `Chart.yaml` doesn't match the values key used for overrides

## Symptoms

- Subchart uses wrong image registry (defaults instead of global override)
- Subchart is unexpectedly disabled or always enabled regardless of values
- Values meant for the subchart are ignored
- `helm template` shows subchart using default values, not parent overrides

## Fix Steps

1. In subchart templates, use `.Values.global.imageRegistry` for global values
2. Fix the `condition` field in parent's `Chart.yaml` to match values path
3. Fix the `alias` to match the key used in parent's values.yaml

## Corrected Configuration

Parent `Chart.yaml`:
```yaml
apiVersion: v2
name: parentchart
version: 0.1.0
dependencies:
  - name: backend
    version: "0.1.0"
    repository: "file://charts/backend"
    condition: backend.enabled
    alias: backend
```

Parent `values.yaml`:
```yaml
global:
  imageRegistry: "registry.example.com"

backend:
  enabled: true
  replicaCount: 2
```

Subchart template (`charts/backend/templates/deployment.yaml`):
```yaml
spec:
  containers:
    - name: {{ .Chart.Name }}
      image: "{{ .Values.global.imageRegistry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

## Verification

```bash
# Update dependencies
cd parentchart && helm dependency update

# Verify global values flow to subchart
helm template myapp . | grep "image:"

# Verify condition works
helm template myapp . --set backend.enabled=false | grep -c "backend"

# Install and verify
helm install myapp .
kubectl get deployment -l app.kubernetes.io/component=backend
```

## Key Takeaways

- Subcharts access global values via `.Values.global.*`
- `condition` in Chart.yaml must match the exact values path (e.g., `backend.enabled`)
- `alias` in Chart.yaml determines the values key for subchart overrides
- Use `helm template` to verify value propagation before installing
