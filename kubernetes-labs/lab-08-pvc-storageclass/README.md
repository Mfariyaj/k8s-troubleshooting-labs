## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4835

## Priority: P3 - Medium | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] stateful-app PVC stuck in Pending - persistent storage not provisioning

### Reporter: Deepak Joshi (Storage Admin)
### Created: 2026-07-01 11:00 IST
### Environment: Production (lab-08 namespace)

---

### Description:

The `stateful-app` needs persistent storage for data files. A PVC was created but it's stuck in **Pending** state — no PersistentVolume is being provisioned. The pod is also Pending because it's waiting for the volume.

The infra team configured the PVC with a specific StorageClass name that they believed was available in the cluster.

---

### What we know:
- PVC `data-pvc` stuck in Pending
- Pod `stateful-app` stuck in Pending (waiting for volume)
- The PVC specifies a StorageClass that might not exist
- Our Docker Desktop cluster has a default `hostpath` provisioner
- No manual PV was pre-created

---

### Observations from on-call:
```
$ kubectl get pvc -n lab-08
NAME       STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS              AGE
data-pvc   Pending                                      premium-ssd-nonexistent   49m

$ kubectl get pods -n lab-08
NAME                            READY   STATUS    RESTARTS   AGE
stateful-app-5b47855847-s8pzv   0/1     Pending   0          49m

$ kubectl get storageclass
NAME                 PROVISIONER          RECLAIMPOLICY   AGE
hostpath (default)   docker.io/hostpath   Delete          258d
```

StorageClass `premium-ssd-nonexistent` doesn't exist! Only `hostpath` is available.

---

### Action Required:
1. Verify which StorageClasses are available in the cluster
2. Fix the PVC to use an available StorageClass (or use the default)
3. Verify PVC gets bound and pod starts
4. Talk to infra team about why they used a non-existent class

---

### Context:
- This was likely copied from an AWS EKS template where `premium-ssd` exists
- On Docker Desktop, use `hostpath` or remove `storageClassName` to use default

### SLA: 2 hours (P3 new feature deployment)
