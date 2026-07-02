## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4821

## Priority: P2 - High | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] web-app pods CrashLoopBackOff after deployment - customer-facing service down

### Reporter: Rahul Sharma (Release Manager)
### Created: 2026-07-01 06:15 IST
### Environment: Production (lab-01 namespace)

---

### Description:

Hi Team,

We deployed the **web-app** service to production at 06:00 IST as part of Release v2.4.1. The deployment completed without errors from CI/CD pipeline, but the pods never came healthy.

PagerDuty alert fired at 06:12 IST — **"web-app health check failing, 0/2 pods ready"**.

The customer portal is DOWN. Business team is escalating. Please investigate ASAP.

---

### What we know:
- Deployment was pushed via ArgoCD (auto-sync)
- Image: `nginx:1.25` (same image used in staging - worked fine there)
- The developer added a custom startup command in this release
- No infra changes were made (nodes healthy, networking fine)
- Rollback is an option but we'd like to understand the root cause first

---

### Observations from on-call:
```
$ kubectl get pods -n lab-01
NAME                       READY   STATUS             RESTARTS   AGE
web-app-5f9c9675-t8bf5    0/1     CrashLoopBackOff   14         49m
web-app-5f9c9675-tsbm8    0/1     CrashLoopBackOff   14         49m
```

Both replicas are crash-looping. Restart count climbing.

---

### Action Required:
1. Investigate why pods are crashing
2. Identify the root cause
3. Apply fix or rollback
4. Update this ticket with RCA

---

### Slack Thread: #incident-channel (pinned)
### Escalation: If not resolved in 30 min, escalate to Engineering Manager

---

### SLA: 30 minutes (P2 production service)
