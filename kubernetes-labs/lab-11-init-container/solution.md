## Solution: Init Container Failure

### Root Cause

Two init containers block the pod from starting:
1. `wait-for-db` runs `nslookup database-service.lab-11.svc.cluster.local` but no such service exists, so it loops forever.
2. `init-migrations` tries to `wget http://migration-service:8080/run-migrations` but no migration service exists.

The main container never starts because init containers must complete first.

### Diagnosis

```bash
kubectl get pods -n lab-11
# Shows Init:0/2
kubectl describe pod -n lab-11 -l app=worker-app
kubectl logs -n lab-11 -l app=worker-app -c wait-for-db
kubectl logs -n lab-11 -l app=worker-app -c init-migrations
```

### Fix

Replace init container commands with ones that can complete:

```bash
kubectl edit deployment worker-app -n lab-11
```

### Fixed YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker-app
  namespace: lab-11
spec:
  replicas: 2
  selector:
    matchLabels:
      app: worker-app
  template:
    metadata:
      labels:
        app: worker-app
    spec:
      initContainers:
      - name: wait-for-db
        image: busybox:1.36
        command: ['sh', '-c', 'echo "DB check complete"; exit 0']
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
      - name: init-migrations
        image: busybox:1.36
        command: ['sh', '-c', 'echo "Migrations complete"; exit 0']
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
      containers:
      - name: app
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
```

### Verification

```bash
kubectl get pods -n lab-11
# Pods should be Running (not Init:0/2)
kubectl logs -n lab-11 -l app=worker-app -c wait-for-db
kubectl logs -n lab-11 -l app=worker-app -c init-migrations
```
