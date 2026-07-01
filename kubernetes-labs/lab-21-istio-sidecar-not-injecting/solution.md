# Solution: Istio Sidecar Not Injecting

## Root Cause

Two issues prevent sidecar injection:

1. **Namespace missing `istio-injection=enabled` label**: The namespace `lab-21-sidecar` does not have the required label for Istio's mutating webhook to trigger automatic sidecar injection.

2. **Pod annotation explicitly disables injection**: The deployment's pod template has `sidecar.istio.io/inject: "false"` annotation, which overrides any namespace-level injection setting.

## Fix Steps

### Step 1: Add the istio-injection label to the namespace

```bash
kubectl label namespace lab-21-sidecar istio-injection=enabled
```

### Step 2: Remove or fix the pod annotation

Remove the `sidecar.istio.io/inject: "false"` annotation from the deployment, or change it to `"true"`.

### Corrected namespace.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: lab-21-sidecar
  labels:
    app: sidecar-lab
    istio-injection: enabled
```

### Corrected broken-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: lab-21-sidecar
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - name: web-app
        image: nginx:1.24
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: web-app
  namespace: lab-21-sidecar
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
```

### Step 3: Restart the deployment to trigger re-injection

```bash
kubectl rollout restart deployment web-app -n lab-21-sidecar
```

## Verification

```bash
# Verify namespace label
kubectl get namespace lab-21-sidecar --show-labels | grep istio-injection

# Verify pods have 2/2 containers (app + istio-proxy)
kubectl get pods -n lab-21-sidecar

# Check sidecar container exists
kubectl get pods -n lab-21-sidecar -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'

# Verify with istioctl
istioctl analyze -n lab-21-sidecar
```
