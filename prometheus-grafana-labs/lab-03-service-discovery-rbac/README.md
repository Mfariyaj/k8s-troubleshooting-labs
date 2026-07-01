# Lab 03: Service Discovery RBAC Misconfiguration

## Difficulty: ⭐⭐⭐ Hard

## Scenario

Prometheus is deployed in Kubernetes with kubernetes_sd_configs to auto-discover pods and services.
After deployment, Prometheus cannot discover any targets despite pods running with correct annotations.
The issue is RBAC — Prometheus lacks the necessary permissions to query the Kubernetes API.

## Error / Symptom

When you check Prometheus logs, you'll observe:

```
level=error ts=... caller=klog.go msg="Failed to watch *v1.Pod: failed to list *v1.Pod: pods is forbidden: 
User \"system:serviceaccount:monitoring:prometheus\" cannot list resource \"pods\" in API group \"\" at the cluster scope"
```

- Prometheus logs show RBAC "forbidden" errors for listing and watching pods
- The /targets page shows no discovered targets from kubernetes_sd_configs
- The service account only has `get` permission, missing `list` and `watch`
- No permissions for `services`, `endpoints`, or `nodes` resources
- Static targets still work, only dynamic service discovery is broken
- The ClusterRole exists but is incomplete
- kubectl auth can-i reveals the permission gaps

## Hints

1. Kubernetes SD needs `list` and `watch` verbs, not just `get` — SD relies on the watch API
2. For `role: pod` SD, Prometheus needs access to the `pods` resource with list+watch+get
3. For `role: service` SD, you also need permissions on `services` and `endpoints`

## Troubleshooting Commands

```bash
# Check Prometheus pod logs for RBAC errors
kubectl logs -n monitoring deploy/prometheus | grep -i "forbidden\|error\|rbac"

# Verify what the service account can do
kubectl auth can-i list pods --as=system:serviceaccount:monitoring:prometheus

# Check the ClusterRole permissions
kubectl get clusterrole prometheus -o yaml

# Check the ClusterRoleBinding
kubectl get clusterrolebinding prometheus -o yaml

# Test API access directly from the pod
kubectl exec -n monitoring deploy/prometheus -- wget -qO- https://kubernetes.default.svc/api/v1/pods --header="Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" --no-check-certificate 2>&1 | head -20
```
