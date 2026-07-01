## Solution: Service Selector Mismatch

### Root Cause

The Service selector labels don't match the pod template labels. When the Service's selector cannot find matching pods, the Endpoints object is empty and no traffic is routed to the pods.

### Diagnosis

```bash
kubectl get pods -n lab-04 --show-labels
kubectl get svc frontend-svc -n lab-04 -o yaml
kubectl get endpoints frontend-svc -n lab-04
```

If endpoints show `<none>`, the selector doesn't match any pods.

### Fix

Ensure service selector labels exactly match pod template labels:

```bash
kubectl get pods -n lab-04 --show-labels
# Note the actual labels on running pods
kubectl patch svc frontend-svc -n lab-04 -p '{"spec":{"selector":{"app":"frontend","tier":"web"}}}'
```

### Fixed YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: lab-04
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
      tier: web
  template:
    metadata:
      labels:
        app: frontend
        tier: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: lab-04
spec:
  type: ClusterIP
  selector:
    app: frontend
    tier: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

### Verification

```bash
kubectl get endpoints frontend-svc -n lab-04
# Should show pod IPs (not <none>)
kubectl run test-curl --image=curlimages/curl --rm -it --restart=Never -n lab-04 -- curl -s frontend-svc
# Should return nginx default page
```
