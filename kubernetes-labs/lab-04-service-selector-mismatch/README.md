## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4827

## Priority: P1 - Critical | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] Frontend service unreachable - pods healthy but no traffic flowing

### Reporter: Priya Menon (QA Lead)
### Created: 2026-07-01 09:15 IST
### Environment: Production (lab-04 namespace)

---

### Description:

URGENT - Production frontend is DOWN for all customers.

This is strange: the pods are all **Running** and healthy (3/3 replicas), but when we curl the service ClusterIP, we get **connection refused**. The load balancer health checks are failing.

We did NOT deploy anything new. Last change was 2 days ago. Someone from the networking team said they "cleaned up some service configs" yesterday — might be related?

---

### What we know:
- 3 frontend pods: ALL Running and Ready (1/1)
- Service `frontend-svc` exists in the namespace
- curl to ClusterIP:80 returns "connection refused"
- Pods individually respond on port 80 (tested with kubectl exec)
- No NetworkPolicy in this namespace

---

### Observations from on-call:
```
$ kubectl get pods -n lab-04
NAME                        READY   STATUS    RESTARTS   AGE
frontend-689d9c9b48-6s4d7   1/1     Running   0          49m
frontend-689d9c9b48-hztbj   1/1     Running   0          49m
frontend-689d9c9b48-nct6m   1/1     Running   0          49m

$ kubectl get svc -n lab-04
NAME           TYPE        CLUSTER-IP      PORT(S)   AGE
frontend-svc   ClusterIP   10.96.xxx.xxx   80/TCP    49m

$ kubectl get endpoints -n lab-04
NAME           ENDPOINTS   AGE
frontend-svc   <none>      49m    ← NO ENDPOINTS!
```

The service has **ZERO endpoints** despite 3 healthy pods!

---

### Action Required:
1. Investigate why the service has no endpoints
2. Compare service selector with pod labels
3. Fix the service to route traffic correctly
4. Verify endpoints populate and traffic flows

---

### Business Impact: All customers affected. Revenue loss ~₹2L/hour.
### SLA: 15 minutes (P1 customer-facing)
