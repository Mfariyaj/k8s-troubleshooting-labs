## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4833

## Priority: P2 - High | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] health-app pods restarting every 30 seconds - liveness probe killing containers

### Reporter: Auto-Alert (PagerDuty)
### Created: 2026-07-01 10:30 IST
### Environment: Production (lab-07 namespace)

---

### Description:

PagerDuty Alert: **"Pod restart count > 20 in namespace lab-07"**

The `health-app` pods start up fine (we can see nginx startup logs) but get **killed every ~30 seconds**. Restart count is climbing rapidly. The application itself seems healthy when we exec into it, but Kubernetes keeps killing it.

This smells like a probe misconfiguration. The developer added health checks in the last release.

---

### What we know:
- 2 replicas, both crash-looping
- Container starts successfully (nginx process runs)
- Kubernetes kills the container after ~15s (liveness probe failure)
- Application serves on port 80 (confirmed via exec + curl)
- Health checks were added in last commit by a junior developer
- Staging didn't catch this because staging has no probes configured

---

### Observations from on-call:
```
$ kubectl get pods -n lab-07
NAME                          READY   STATUS             RESTARTS      AGE
health-app-c887cfd44-bjmwz   0/1     CrashLoopBackOff   21            49m
health-app-c887cfd44-p9x9j   0/1     CrashLoopBackOff   21            49m

$ kubectl describe pod -n lab-07 health-app-c887cfd44-bjmwz | grep -A5 "Last State"
    Last State:  Terminated
      Reason:    Completed
      Exit Code: 0
    Restart Count: 21
    Liveness:    http-get http://:8080/healthz ...
```

Notice: Liveness probe is checking port **8080** path `/healthz`... but nginx runs on port 80!

---

### Action Required:
1. Check what port/path the liveness and readiness probes are configured for
2. Compare with what the application actually serves
3. Fix the probe configuration to match the real application endpoints
4. Verify pods stabilize (restart count stops increasing)

---

### Dev team comment:
> "I copied the probe config from our Go service template. Forgot to change the port and path for nginx."

### SLA: 30 minutes (P2 service degraded)
