## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4829

## Priority: P2 - High | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] config-app pods stuck in ContainerCreating - config management broken

### Reporter: Vikram Singh (SRE)
### Created: 2026-07-01 09:45 IST
### Environment: Production (lab-05 namespace)

---

### Description:

The `config-app` deployment has 2 pods stuck in **ContainerCreating** for almost an hour. These pods require nginx configuration files mounted from ConfigMaps.

We created the ConfigMap but the pods still won't start. Events are showing volume mount failures.

---

### What we know:
- Pods need ConfigMap mounted as volume for nginx config
- A ConfigMap named `app-config` exists in the namespace
- The deployment references volume mounts from ConfigMap(s)
- Pods stuck in ContainerCreating (not CrashLoopBackOff — means container hasn't started at all)
- Likely a volume/configmap reference issue

---

### Observations from on-call:
```
$ kubectl get pods -n lab-05
NAME                          READY   STATUS              RESTARTS   AGE
config-app-787c655544-7vq9b   0/1     ContainerCreating   0          49m
config-app-787c655544-x64t6   0/1     ContainerCreating   0          49m

$ kubectl get configmap -n lab-05
NAME         DATA   AGE
app-config   2      49m
```

ConfigMap exists with 2 data keys, but pods won't start.

---

### Action Required:
1. Describe the pod and check events for volume mount errors
2. Compare ConfigMap names referenced in deployment vs what actually exists
3. Fix the volume references to point to correct ConfigMap(s)
4. Verify pods start and nginx serves with correct config

---

### Hint from developer (Slack):
> "I think the deployment YAML was copy-pasted from another project. The ConfigMap names might not match."

### SLA: 45 minutes (P2 internal service)
