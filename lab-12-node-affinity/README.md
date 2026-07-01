# 🎫 INCIDENT TICKET - INC-4843

## Priority: P3 - Medium | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] gpu-workload pod Pending - node affinity can't find matching node

### Reporter: Rajesh Verma (ML Engineering)
### Created: 2026-07-01 12:00 IST
### Environment: Production (lab-12 namespace)

---

### Description:

The ML team deployed a GPU workload but the pod is stuck in **Pending**. They configured node affinity to only schedule on GPU nodes, but our Docker Desktop cluster doesn't have any nodes with GPU labels.

This was deployed with hard affinity (`requiredDuringSchedulingIgnoredDuringExecution`), meaning it will NEVER schedule unless a node matches.

---

### What we know:
- Pod requires nodes with label `accelerator/gpu=nvidia-tesla-v100` or `nvidia-a100`
- Pod also requires `node-type=high-memory`
- Our cluster has 1 node: `docker-desktop` (no GPU labels exist)
- The affinity is a HARD requirement (required, not preferred)
- The actual workload is just nginx (doesn't need a GPU — this is misconfigured)

---

### Observations from on-call:
```
$ kubectl get pods -n lab-12
NAME                            READY   STATUS    RESTARTS   AGE
gpu-workload-696d9f94df-twgl7   0/1     Pending   0          49m

$ kubectl describe pod -n lab-12 gpu-workload-696d9f94df-twgl7 | grep -A3 Events
Events:
  Warning  FailedScheduling  0/1 nodes are available: 1 node(s) didn't match 
  Pod's node affinity/selector.

$ kubectl get nodes --show-labels | grep gpu
(nothing - no GPU labels on any node)
```

---

### Action Required:
1. Check what node affinity/selector the pod requires
2. Check what labels actually exist on cluster nodes
3. Fix the issue using one of these approaches:
   - **Option A**: Remove the node affinity entirely (if GPU not needed)
   - **Option B**: Change to `preferredDuringScheduling` (soft preference)
   - **Option C**: Label a node to match (for testing): `kubectl label node docker-desktop accelerator/gpu=nvidia-tesla-v100`
4. Verify pod gets scheduled and starts

---

### ML Team's response:
> "We copied this from our AWS EKS config where we have p3.2xlarge GPU instances. This is just a test deployment — remove the affinity."

### SLA: 2 hours (P3 non-critical workload)
