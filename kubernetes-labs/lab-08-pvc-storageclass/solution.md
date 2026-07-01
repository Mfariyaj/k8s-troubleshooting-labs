## Solution: PVC StorageClass Issue

### Root Cause

The PersistentVolumeClaim references a StorageClass named `premium-ssd-nonexistent` which does not exist in the cluster. The PVC remains in Pending state and the pod cannot start because its volume cannot be provisioned.

### Diagnosis

```bash
kubectl get pvc -n lab-08
kubectl describe pvc data-pvc -n lab-08
kubectl get storageclass
```

Events will show: `storageclass.storage.k8s.io "premium-ssd-nonexistent" not found`

### Fix

Delete the broken PVC and recreate with a valid StorageClass:

```bash
kubectl get storageclass
# Note your cluster's available StorageClass (e.g., "standard")

kubectl delete pvc data-pvc -n lab-08
kubectl delete deployment stateful-app -n lab-08

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
  namespace: lab-08
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 10Gi
EOF

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stateful-app
  namespace: lab-08
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stateful-app
  template:
    metadata:
      labels:
        app: stateful-app
    spec:
      containers:
      - name: app
        image: nginx:1.25
        ports:
        - containerPort: 80
        volumeMounts:
        - name: data-storage
          mountPath: /data
      volumes:
      - name: data-storage
        persistentVolumeClaim:
          claimName: data-pvc
EOF
```

### Verification

```bash
kubectl get pvc -n lab-08
# STATUS should be Bound
kubectl get pods -n lab-08
# Pod should be Running
kubectl exec -n lab-08 deploy/stateful-app -- df -h /data
```
