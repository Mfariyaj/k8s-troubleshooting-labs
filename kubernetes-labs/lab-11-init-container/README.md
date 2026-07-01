# 🎫 INCIDENT TICKET - INC-4841

## Priority: P2 - High | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] worker-app stuck in Init:0/2 - init containers waiting forever

### Reporter: Meera Nair (DevOps Engineer)
### Created: 2026-07-01 11:45 IST
### Environment: Production (lab-11 namespace)

---

### Description:

The `worker-app` pods have been stuck in **Init:0/2** state for almost an hour. The main application container never starts because the init containers never complete.

The init containers are designed to:
1. Wait for a database service to be available (DNS lookup)
2. Run database migrations via HTTP call

Neither init container can succeed because the services they depend on don't exist in this namespace.

---

### What we know:
- 2 replicas, both stuck in Init:0/2 (first init container hasn't completed)
- Init container #1: `wait-for-db` — does DNS lookup for `database-service.lab-11.svc.cluster.local`
- Init container #2: `init-migrations` — calls `http://migration-service:8080/run-migrations`
- Neither `database-service` nor `migration-service` exist in the namespace
- The worker app itself doesn't actually need these services (they were added "for safety")
- Main app is a simple nginx container

---

### Observations from on-call:
```
$ kubectl get pods -n lab-11
NAME                          READY   STATUS     RESTARTS   AGE
worker-app-68c9856b99-bpsfj   0/1     Init:0/2   0          49m
worker-app-68c9856b99-xwvcr   0/1     Init:0/2   0          49m

$ kubectl logs -n lab-11 worker-app-68c9856b99-bpsfj -c wait-for-db
nslookup: can't resolve 'database-service.lab-11.svc.cluster.local'
Waiting for database...
nslookup: can't resolve 'database-service.lab-11.svc.cluster.local'
Waiting for database...
(repeats forever)
```

---

### Action Required:
1. Check what services the init containers are waiting for
2. Decide: Create the missing services OR remove unnecessary init containers
3. Since the main app is nginx (doesn't need a DB), remove the init containers
4. Alternatively, create a dummy service to satisfy the DNS check
5. Verify pods complete init and reach Running state

---

### Options:
- **Option A**: Remove init containers from deployment (recommended - they're unnecessary)
- **Option B**: Create the missing Service objects (quick hack)

### SLA: 45 minutes (P2 background workers not processing)
