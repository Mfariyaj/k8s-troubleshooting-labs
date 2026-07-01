# 🎫 INCIDENT TICKET - INC-4831

## Priority: P1 - Critical | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] database-app pod CreateContainerConfigError - database service down

### Reporter: Sanjay Kumar (DBA Team)
### Created: 2026-07-01 10:00 IST
### Environment: Production (lab-06 namespace)

---

### Description:

**CRITICAL** — The PostgreSQL database pod won't start. All dependent microservices are failing with connection errors.

The database pod is showing `CreateContainerConfigError`. The DBA team says they followed the docs and configured the deployment to read credentials from a Kubernetes Secret, but they're not sure if the Secret was ever created.

---

### What we know:
- Pod uses `postgres:15` image
- Environment variables reference a Secret named `db-credentials`
- Pod never even starts (CreateContainerConfigError, NOT CrashLoopBackOff)
- This tells us it's a config issue BEFORE the container runs
- The DBA team was supposed to create the secret but "thought DevOps was handling it"

---

### Observations from on-call:
```
$ kubectl get pods -n lab-06
NAME                            READY   STATUS                       RESTARTS   AGE
database-app-7b88b6d78c-drg8b   0/1     CreateContainerConfigError   0          49m

$ kubectl get secrets -n lab-06
NAME                  TYPE                                  DATA   AGE
default-token-xxxxx   kubernetes.io/service-account-token   3      49m
```

No `db-credentials` secret exists!

---

### Action Required:
1. Confirm which secret(s) and key(s) the deployment expects
2. Create the missing secret with required keys
3. Verify the pod starts and PostgreSQL initializes
4. Document the secret creation process for the DBA team

---

### ⚠️ Important:
- Use reasonable credentials (username: `admin`, password: `your-choice`, database: `appdb`)
- This is blocking 5 downstream services

### SLA: 20 minutes (P1 database down)
