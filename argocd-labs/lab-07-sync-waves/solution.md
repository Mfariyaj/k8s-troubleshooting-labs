## Solution: Sync Waves Misconfigured — Database Deploys After App

### Root Cause
The web-app has `sync-wave: "1"` and postgres-db has `sync-wave: "3"`. The web-app init-container waits for the database (`nc -z postgres-db 5432`), but the database doesn't deploy until wave 3. Pods are stuck in `Init:0/1` forever.

### Step-by-Step Fix

1. Identify the ordering issue:
   ```bash
   grep -r "sync-wave" manifests/
   kubectl get pods -n sync-waves-lab
   ```
2. Swap sync waves: DB=1 (first), App=3 (after DB is ready)

### Fixed YAML — manifests/db-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-db
  namespace: sync-waves-lab
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-db
  template:
    metadata:
      labels:
        app: postgres-db
    spec:
      containers:
        - name: postgres
          image: postgres:15
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_DB
              value: appdb
            - name: POSTGRES_USER
              value: admin
            - name: POSTGRES_PASSWORD
              value: password123
```

### Fixed YAML — manifests/app-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: sync-waves-lab
  annotations:
    argocd.argoproj.io/sync-wave: "3"
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      initContainers:
        - name: wait-for-db
          image: busybox:1.36
          command: ['sh', '-c', 'until nc -z postgres-db 5432; do sleep 2; done']
      containers:
        - name: app
          image: nginx:1.21
          ports:
            - containerPort: 8080
```

### Verification
```bash
argocd app sync sync-waves-app
argocd app wait sync-waves-app --health
kubectl get pods -n sync-waves-lab
# postgres-db Running, web-app Running (init completed)
```
