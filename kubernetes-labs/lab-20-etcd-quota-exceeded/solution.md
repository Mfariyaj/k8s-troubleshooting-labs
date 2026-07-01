## Solution: etcd Quota Exceeded

### Root Cause

A runaway Job (`configmap-flood`) created 200 large ConfigMaps (~512KB each), simulating etcd space exhaustion. When etcd reaches its storage quota, the API server rejects all write operations with `etcdserver: mvcc: database space exceeded`. Reads still work but no new resources can be created.

### Diagnosis

```bash
kubectl get pods -n lab-20-etcd
kubectl get configmaps -n lab-20-etcd | wc -l
kubectl get events -n lab-20-etcd
# If etcd is actually full:
# kubectl get pods  # would fail with "etcdserver: mvcc: database space exceeded"
```

### Fix

Step 1: Delete the leaked ConfigMaps:

```bash
kubectl delete configmaps -n lab-20-etcd -l leaked=true
# Or delete all flood configmaps:
kubectl delete configmaps -n lab-20-etcd -l app=configmap-flood
```

Step 2: Delete the flood job:

```bash
kubectl delete job configmap-flood -n lab-20-etcd
```

Step 3 (if etcd is actually full — requires cluster admin access):

```bash
# Get current etcd revision
rev=$(ETCDCTL_API=3 etcdctl endpoint status --write-out="json" | jq '.[0].Status.header.revision')

# Compact old revisions
ETCDCTL_API=3 etcdctl compact $rev

# Defragment etcd
ETCDCTL_API=3 etcdctl defrag

# (Optional) Increase etcd quota
# Edit etcd manifest: /etc/kubernetes/manifests/etcd.yaml
# Add: --quota-backend-bytes=8589934592  (8GB)

# Disarm the alarm
ETCDCTL_API=3 etcdctl alarm disarm
```

### Verification

```bash
kubectl get configmaps -n lab-20-etcd | wc -l
# Should show only a few (not 200+)
kubectl get pods -n lab-20-etcd
# critical-api pods should be Running
kubectl scale deployment critical-api -n lab-20-etcd --replicas=3
# Should succeed if etcd is healthy
kubectl get pods -n lab-20-etcd
# Should show 3 running pods
```

### Prevention

```bash
# Set ResourceQuotas to limit configmap count:
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: configmap-quota
  namespace: lab-20-etcd
spec:
  hard:
    configmaps: "50"
EOF
```
