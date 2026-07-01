# Lab 03 - Service Discovery RBAC

## Root Cause

The ClusterRole for Prometheus is missing `list` and `watch` permissions on the `pods`
resource. Prometheus uses Kubernetes service discovery (kubernetes_sd_configs) which requires
these permissions to discover and watch pod targets.

## Symptoms

- Prometheus logs show `403 Forbidden` errors for Kubernetes API calls
- Service discovery returns no targets
- Targets page is empty despite pods running in the cluster

## Fix Steps

1. Open `rbac.yaml`
2. Add `list` and `watch` verbs to the `pods` resource in the ClusterRole

## Corrected Configuration

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
  - apiGroups: [""]
    resources:
      - nodes
      - nodes/proxy
      - services
      - endpoints
      - pods
    verbs: ["get", "list", "watch"]
  - apiGroups: ["extensions"]
    resources:
      - ingresses
    verbs: ["get", "list", "watch"]
```

## Verification

```bash
# Apply the fixed RBAC
kubectl apply -f rbac.yaml

# Restart Prometheus pod
kubectl rollout restart deployment prometheus

# Check Prometheus logs for RBAC errors
kubectl logs -l app=prometheus --tail=20 | grep -i "forbidden"

# Verify targets are discovered
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length'
```

## Key Takeaways

- Kubernetes SD requires `get`, `list`, and `watch` on discovered resources
- Always check Prometheus logs for 403 errors when SD returns no targets
- Use `kubectl auth can-i` to verify ServiceAccount permissions
