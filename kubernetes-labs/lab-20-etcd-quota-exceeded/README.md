# Lab 20: ETCD Quota Exceeded — Database Space Exhaustion

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your production Kubernetes cluster suddenly starts rejecting all write operations. Running
pods continue to work, but no new pods can be created, no configmaps can be updated, and
the scheduler cannot bind pods to nodes. Investigation reveals the API server is returning
"etcdserver: mvcc: database space exceeded" errors. A runaway CI/CD pipeline has been
leaking hundreds of large ConfigMaps on every deployment for weeks, slowly filling etcd
until it hit the 2GB default quota. This lab simulates the condition by flooding a namespace.

## Symptoms

```bash
$ kubectl run test-pod --image=nginx -n lab-20-etcd
Error from server (InternalError): Internal error occurred: etcdserver: mvcc: database space exceeded

$ kubectl apply -f some-resource.yaml
Error from server (InternalError): Internal error occurred: etcdserver: mvcc: database space exceeded

$ kubectl get pods -n lab-20-etcd
NAME                           READY   STATUS    RESTARTS   AGE
critical-api-5d4c3b2a1f-abc12  1/1     Running   0          10m
critical-api-5d4c3b2a1f-def34  1/1     Running   0          10m

$ kubectl get configmaps -n lab-20-etcd --no-headers | wc -l
201

$ kubectl get events -n lab-20-etcd
No resources found.  (Can't write new events either!)
```

## Error Output

```bash
$ kubectl create configmap test --from-literal=key=value -n lab-20-etcd
Error from server (InternalError): Internal error occurred: etcdserver: mvcc: database space exceeded

$ kubectl scale deployment critical-api --replicas=5 -n lab-20-etcd
Error from server (InternalError): Internal error occurred: etcdserver: mvcc: database space exceeded

$ kubectl describe node worker-1 | grep -A5 Conditions
  Type             Status  Message
  ----             ------  -------
  MemoryPressure   False   
  DiskPressure     False   
  PIDPressure      False   
  Ready            True    kubelet is posting ready status

# Note: Reads still work fine!
$ kubectl get pods --all-namespaces | wc -l
47

# The API server is healthy for reads
$ kubectl cluster-info
Kubernetes control plane is running at https://10.0.0.1:6443
```

## Hints

<details>
<summary>Hint 1 (Conceptual)</summary>
etcd has a configurable storage quota (default 2GB, max recommended 8GB). When the database exceeds this quota, etcd triggers an alarm and stops accepting write requests (PUT, POST, DELETE). Read requests (GET, LIST) continue to work. The fix involves: identifying what filled etcd, removing it, then compacting and defragmenting the database.
</details>

<details>
<summary>Hint 2 (Direction)</summary>
In this lab, the leak source is ConfigMaps labeled `leaked=true` in the namespace. Check `kubectl get configmaps -n lab-20-etcd -l leaked=true --no-headers | wc -l`. In production, common sources include: Helm release secrets, orphaned ConfigMaps from rolling updates, event storms, and CRD instances from broken operators. You need to bulk-delete these resources.
</details>

<details>
<summary>Hint 3 (Solution Path)</summary>
(1) Identify leaked resources: `kubectl get cm -n lab-20-etcd -l leaked=true`. (2) Bulk delete them: `kubectl delete configmaps -n lab-20-etcd -l leaked=true`. (3) In a real scenario, after deletion you'd need to: `etcdctl compact $(etcdctl endpoint status --write-out=json | jq '.[] | .Status.header.revision')`, then `etcdctl defrag`, then `etcdctl alarm disarm`. (4) Prevent recurrence: set ResourceQuota on the namespace, add LimitRange, implement garbage collection for the CI pipeline.
</details>

## Troubleshooting Commands

```bash
# Count all configmaps in the namespace
kubectl get configmaps -n lab-20-etcd --no-headers | wc -l

# Find leaked configmaps by label
kubectl get configmaps -n lab-20-etcd -l leaked=true --no-headers | wc -l

# Check total resource count across all namespaces
kubectl get all --all-namespaces 2>&1 | wc -l

# Estimate etcd size (if you have etcdctl access)
# etcdctl endpoint status --write-out=table
# etcdctl alarm list

# Check for resource quotas (should exist to prevent this)
kubectl get resourcequota -n lab-20-etcd

# Look at the job that caused the leak
kubectl get jobs -n lab-20-etcd
kubectl describe job configmap-flood -n lab-20-etcd
kubectl logs job/configmap-flood -n lab-20-etcd

# Check configmap sizes
kubectl get configmap -n lab-20-etcd -l leaked=true -o json | jq '[.items[] | {name: .metadata.name, dataSize: (.data | to_entries | map(.value | length) | add)}] | sort_by(.dataSize) | reverse | .[0:5]'

# Identify what's consuming the most space in etcd
kubectl get configmaps -n lab-20-etcd -l leaked=true -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.creationTimestamp}{"\n"}{end}' | tail -10

# Bulk delete leaked resources
kubectl delete configmaps -n lab-20-etcd -l leaked=true

# After cleanup, check if writes work again
kubectl create configmap test-write --from-literal=test=success -n lab-20-etcd

# In production, compact and defrag etcd:
# REVISION=$(etcdctl endpoint status --write-out=json | jq '.[0].Status.header.revision')
# etcdctl compact $REVISION
# etcdctl defrag --cluster
# etcdctl alarm disarm

# Prevent recurrence with ResourceQuota
# kubectl apply -f resource-quota.yaml
```

## Expected Resolution Time: 20-30 minutes

## What You'll Learn

- How etcd storage quotas work and what triggers the alarm
- The asymmetric behavior: reads succeed but writes fail when quota is exceeded
- Common causes of etcd space exhaustion in production
- How to identify resource leaks (ConfigMaps, Secrets, Events, CRs)
- The etcd maintenance workflow: compact → defrag → alarm disarm
- Preventive measures: ResourceQuota, LimitRange, garbage collection policies
- How Helm release history and CI/CD pipelines can silently fill etcd
- The difference between etcd logical size and physical size after compaction
