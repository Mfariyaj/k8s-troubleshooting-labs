## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# 🎫 INCIDENT TICKET - INC-4825

## Priority: P3 - Medium | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] resource-hungry-app stuck in Pending - batch processing halted

### Reporter: Amit Patel (Data Engineering Lead)
### Created: 2026-07-01 08:00 IST
### Environment: Production (lab-03 namespace)

---

### Description:

Hi Team,

We deployed the `resource-hungry-app` for our nightly batch processing pipeline. The pod has been stuck in **Pending** state for over an hour. The batch job hasn't started and we're missing our SLA for the daily data export to the client.

The data team configured the resource requests based on "what they think the job needs" — they mentioned they set it high to "be safe".

---

### What we know:
- Single replica deployment
- Pod never gets scheduled to any node
- No node scaling events triggered
- The cluster has 1 node (Docker Desktop) with ~8GB RAM and 4 CPUs
- No other pending pods in the cluster

---

### Observations from on-call:
```
$ kubectl get pods -n lab-03
NAME                                   READY   STATUS    RESTARTS   AGE
resource-hungry-app-6647ffdc7f-t749q   0/1     Pending   0          49m
```

The pod has been Pending for 49 minutes with no progress.

---

### Action Required:
1. Find out why the pod can't be scheduled
2. Check node capacity vs pod resource requests
3. Fix the resource requests to reasonable values
4. Verify the pod starts successfully

---

### Context:
- The application is a simple nginx-based batch proxy
- It does NOT need 128GB of RAM (someone clearly over-estimated)
- Talk to data team about proper resource sizing after fix

### SLA: 2 hours (P3 batch processing)
