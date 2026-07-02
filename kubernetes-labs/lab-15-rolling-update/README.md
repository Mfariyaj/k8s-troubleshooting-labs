## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4849

## Priority: P1 - Critical | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] payment-service rolling update stuck - new pods never become Ready, old pods still serving

### Reporter: Ajay Menon (Release Manager)
### Created: 2026-07-01 12:45 IST
### Environment: Production (lab-15 namespace)

---

### Description:

We initiated a rolling update for `payment-service` to deploy v2 with a new health endpoint. The rollout is **stuck** — new pods start but never become Ready (0/1), so the old pods are never terminated.

The deployment is in a partial state: some new v2 pods are Running but not Ready, while old pods continue serving (but we need v2 deployed for a critical payment fix).

`kubectl rollout status` hangs indefinitely.

---

### What we know:
- Deployment strategy: RollingUpdate (maxSurge=1, maxUnavailable=0)
- 3 desired replicas
- New pods start (Running) but readinessProbe FAILS → never marked Ready
- Since maxUnavailable=0, old pods can't be removed until new ones are Ready
- The readiness probe checks `/api/v2/health` on port `9090`
- But the actual container is nginx serving on port `80` (no `/api/v2/health` endpoint exists!)
- The liveness probe also checks port 9090 → pods eventually get killed → CrashLoopBackOff

---

### Observations from on-call:
```
$ kubectl get pods -n lab-15
NAME                               READY   STATUS             RESTARTS      AGE
payment-service-6dcf66888f-c4w5r   0/1     CrashLoopBackOff   19            49m
payment-service-6dcf66888f-szkcc   0/1     CrashLoopBackOff   19            49m
payment-service-6dcf66888f-vm5kk   0/1     CrashLoopBackOff   19            49m

$ kubectl rollout status deployment/payment-service -n lab-15
Waiting for deployment "payment-service" rollout to finish: 0 of 3 updated replicas are available...
(hangs forever)

$ kubectl describe pod -n lab-15 payment-service-6dcf66888f-c4w5r | grep -A3 Readiness
    Readiness: http-get http://:9090/api/v2/health delay=5s timeout=1s period=3s
    Liveness:  http-get http://:9090/api/v2/alive delay=15s timeout=1s period=10s
```

---

### Action Required:
1. Identify why readiness probe is failing (wrong port and path)
2. Fix the readiness and liveness probes to match the actual application (nginx on port 80)
3. Apply the fix — deployment should automatically complete rollout
4. Verify all 3 replicas become Ready
5. Alternatively: rollback first (`kubectl rollout undo`), fix YAML, then redeploy

---

### Decision needed:
- **Option A**: Fix forward (edit deployment with correct probes)
- **Option B**: Rollback → fix YAML → redeploy

Both are acceptable. Choose based on confidence.

### SLA: 15 minutes (P1 payment processing affected)
