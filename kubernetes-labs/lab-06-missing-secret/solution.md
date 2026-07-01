## Solution: Missing Secret

### Root Cause

The pod references a Secret named `db-credentials` with keys `username`, `password`, and `database`, but this Secret does not exist in the namespace. Kubernetes cannot inject the environment variables, and the pod stays in `CreateContainerConfigError`.

### Diagnosis

```bash
kubectl get pods -n lab-06
kubectl describe pod -n lab-06 -l app=database-app
kubectl get secrets -n lab-06
```

Events will show: `secret "db-credentials" not found`

### Fix

Create the missing Secret:

```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=secretpassword123 \
  --from-literal=database=appdb \
  -n lab-06
```

Or apply as YAML:

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
  namespace: lab-06
type: Opaque
stringData:
  username: admin
  password: secretpassword123
  database: appdb
EOF
```

### Verification

```bash
kubectl get secrets -n lab-06
# Should show db-credentials
kubectl get pods -n lab-06
# Pod should transition to Running
kubectl logs -n lab-06 -l app=database-app
# PostgreSQL should start successfully
```
