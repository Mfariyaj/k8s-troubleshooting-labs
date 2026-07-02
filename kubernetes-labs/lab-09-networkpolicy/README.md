## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4837

## Priority: P1 - Critical | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] Frontend can't reach backend API after NetworkPolicy deployment - complete service isolation

### Reporter: Kiran Rao (Security Team Lead)
### Created: 2026-07-01 11:15 IST
### Environment: Production (lab-09 namespace)

---

### Description:

The security team deployed NetworkPolicies 1 hour ago as part of the "Zero Trust Networking" initiative. Since then, the **frontend can't reach the backend API at all**. All inter-service communication is broken.

Both frontend and backend pods are Running fine individually — the issue is network connectivity between them.

Security team says: "We applied a deny-all policy and then added allow rules for monitoring. We might have forgotten to allow frontend→backend traffic."

---

### What we know:
- Both frontend and backend pods are Running (healthy individually)
- Backend service `backend-svc` exists and has endpoints
- Frontend gets **timeout** when trying to reach backend-svc
- A `deny-all-ingress` NetworkPolicy was applied (blocks ALL traffic)
- An allow rule exists but only for `role: monitoring` pods
- Frontend pods have label `role: frontend` (not `role: monitoring`!)

---

### Observations from on-call:
```
$ kubectl get pods -n lab-09
NAME                               READY   STATUS    RESTARTS   AGE
backend-api-6cbd8dc7f9-cc624      1/1     Running   0          49m
backend-api-6cbd8dc7f9-rdrlq      1/1     Running   0          49m
frontend-client-665db56d78-b6hch   1/1     Running   0          49m

$ kubectl get networkpolicy -n lab-09
NAME                         POD-SELECTOR   AGE
deny-all-ingress             <none>         49m
allow-backend-from-monitoring  app=backend-api  49m
```

---

### Test (from frontend pod):
```bash
kubectl exec -n lab-09 <frontend-pod> -- curl -s --connect-timeout 5 http://backend-svc
# TIMEOUT - no response
```

---

### Action Required:
1. Review existing NetworkPolicies and understand what they block
2. Identify why frontend traffic is being denied
3. Create/modify NetworkPolicy to allow frontend → backend on port 80
4. Also fix egress if needed (deny-all blocks egress too!)
5. Verify frontend can reach backend-svc
6. Don't remove the deny-all policy (security requirement) — add targeted allows

---

### ⚠️ Constraint:
- The deny-all policy MUST stay (security compliance)
- You need to ADD a new allow policy, not remove the deny

### SLA: 20 minutes (P1 all services broken)
