## Solution: Sidecar Injection Failure

### Root Cause

Three bugs prevent the sidecar from working:
1. **Annotation typo**: `sidecar.istio.io/injectt` (double 't') should be `sidecar.istio.io/inject`
2. **ConfigMap error**: `REDIRECT_PORT` and `INBOUND_CAPTURE_PORT` are set to `"0"` — the init container checks for this and exits with error
3. **iptables syntax**: `--to-ports` is wrong (should be `--to-port` for REDIRECT target)

The init container fails, blocking the main containers from starting.

### Diagnosis

```bash
kubectl get pods -n lab-18-sidecar
# Shows Init:CrashLoopBackOff
kubectl logs -n lab-18-sidecar -l app=notification-svc -c istio-init
kubectl describe pod -n lab-18-sidecar -l app=notification-svc
kubectl get cm istio-proxy-config -n lab-18-sidecar -o yaml
```

### Fix

1. Fix the ConfigMap ports:

```bash
kubectl edit cm istio-proxy-config -n lab-18-sidecar
# Change REDIRECT_PORT from "0" to "15001"
# Change INBOUND_CAPTURE_PORT from "0" to "15006"
```

2. Fix the annotation and iptables command in the deployment:

```bash
kubectl edit deployment notification-svc -n lab-18-sidecar
```

### Fixed ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: istio-proxy-config
  namespace: lab-18-sidecar
data:
  REDIRECT_PORT: "15001"
  INBOUND_CAPTURE_PORT: "15006"
  PROXY_ADMIN_PORT: "15000"
  OUTBOUND_PORT: "15001"
  INBOUND_PORT: "15006"
  SERVICE_CIDR: "10.96.0.0/12"
  POD_CIDR: "10.244.0.0/16"
  PROXY_UID: "1337"
  PROXY_GID: "1337"
```

### Fixed Deployment annotations

```yaml
annotations:
  sidecar.istio.io/inject: "true"  # Fix: removed extra 't'
```

### Fixed init container command (key section)

```yaml
command:
  - /bin/sh
  - -c
  - |
    set -e
    echo "Setting up iptables rules..."
    echo "Redirect port: $REDIRECT_PORT"
    if [ "$REDIRECT_PORT" = "0" ] || [ -z "$REDIRECT_PORT" ]; then
      echo "Error: invalid redirect port"; exit 1
    fi
    echo "iptables -t nat -A PREROUTING -p tcp --to-port $REDIRECT_PORT -j REDIRECT"
    echo "iptables rules configured successfully"
```

### Verification

```bash
kubectl get pods -n lab-18-sidecar
# All pods should be Running (not Init:CrashLoopBackOff)
kubectl logs -n lab-18-sidecar -l app=notification-svc -c istio-init
# Should show "iptables rules configured successfully"
```
