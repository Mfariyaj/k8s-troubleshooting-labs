## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4839

## Priority: P2 - High | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] controller-app getting "forbidden" errors - RBAC misconfiguration

### Reporter: Arun Krishnan (Backend Developer)
### Created: 2026-07-01 11:30 IST
### Environment: Production (lab-10 namespace)

---

### Description:

We deployed a controller application that needs to list pods in its namespace (for service discovery). The pod is Running but the application logs show **"forbidden"** errors when trying to call the Kubernetes API.

We created a ServiceAccount, Role, and RoleBinding but something is misconfigured. The pod can't do what it needs to do.

---

### What we know:
- Pod is Running (1/1 Ready) — no crash, just permission errors in logs
- The pod uses ServiceAccount `app-sa`
- A Role `pod-reader` exists in the namespace
- A RoleBinding `pod-reader-binding` exists
- The application tries to: `kubectl get pods -n lab-10`
- It gets: "forbidden: User cannot list resource pods"

---

### Observations from on-call:
```
$ kubectl get pods -n lab-10
NAME                              READY   STATUS    RESTARTS   AGE
controller-app-5bbc8bf9b6-jhx2x   1/1     Running   0          49m

$ kubectl logs -n lab-10 controller-app-5bbc8bf9b6-jhx2x
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:lab-10:app-sa" 
cannot list resource "pods" in API group "" in the namespace "lab-10"

$ kubectl auth can-i list pods --as=system:serviceaccount:lab-10:app-sa -n lab-10
no
```

---

### Action Required:
1. Check what the Role `pod-reader` actually allows (might be wrong resource/verb)
2. Check if the RoleBinding binds to the correct ServiceAccount
3. Fix the RBAC so `app-sa` can list pods in namespace lab-10
4. Verify with `kubectl auth can-i`
5. Check pod logs clear up after fix

---

### Developer's comment:
> "I created the Role and Binding from a template. Maybe I forgot to change the ServiceAccount name or the resource type."

### SLA: 45 minutes (P2 service discovery broken)
