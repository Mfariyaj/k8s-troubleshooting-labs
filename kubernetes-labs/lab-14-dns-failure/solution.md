## Solution: DNS Failure

### Root Cause

The `api-gateway` deployment has `dnsPolicy: "None"` with only `8.8.8.8` as the nameserver. This external DNS cannot resolve cluster-internal service names like `user-service.lab-14.svc.cluster.local`. The search domain `lab-14.svc.cluster.local` is useless with an external nameserver.

Additionally, the curl command targets `user-service:8080` but the actual service is named `users-svc`.

### Diagnosis

```bash
kubectl get pods -n lab-14
kubectl logs -n lab-14 -l app=api-gateway
kubectl get svc -n lab-14
kubectl exec -n lab-14 -l app=api-gateway -- cat /etc/resolv.conf
```

Logs show: `curl: (6) Could not resolve host: user-service`

### Fix

Change `dnsPolicy` to `ClusterFirst` (default) so the pod uses the cluster DNS:

```bash
kubectl edit deployment api-gateway -n lab-14
```

Remove `dnsPolicy: "None"` and `dnsConfig` section, and fix the service name in the curl command.

### Fixed YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: lab-14
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      dnsPolicy: ClusterFirst
      containers:
      - name: curl-client
        image: curlimages/curl:latest
        command: ["sh", "-c", "while true; do echo 'Trying to reach user-service...'; curl -s --connect-timeout 5 http://users-svc:8080/users || echo 'FAILED'; sleep 10; done"]
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
          limits:
            memory: "64Mi"
            cpu: "50m"
```

### Verification

```bash
kubectl logs -n lab-14 -l app=api-gateway
# Should no longer show DNS resolution failures
kubectl exec -n lab-14 -l app=api-gateway -- cat /etc/resolv.conf
# Should show cluster DNS (e.g., 10.96.0.10)
kubectl exec -n lab-14 -l app=api-gateway -- nslookup users-svc.lab-14.svc.cluster.local
```
