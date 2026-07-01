# 🎫 INCIDENT TICKET - INC-4823

## Priority: P2 - High | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] api-service pods stuck in ImagePullBackOff - API gateway returning 503

### Reporter: Neha Gupta (Backend Lead)
### Created: 2026-07-01 07:30 IST
### Environment: Production (lab-02 namespace)

---

### Description:

Hey,

We pushed a new microservice `api-service` to production as part of the API v3 migration. The pods are stuck and never start. Our API gateway is returning **503 Service Unavailable** for all `/v3/*` endpoints.

The deploy was approved after passing all staging tests. Dev team says "it works on my machine" and staging is fine.

---

### What we know:
- New service deployed first time to production
- 3 replicas requested, 0 running
- Container registry: DockerHub (public image)
- The developer is on leave today — we don't have exact image details
- No network policy changes were made

---

### Observations from on-call:
```
$ kubectl get pods -n lab-02
NAME                           READY   STATUS             RESTARTS   AGE
api-service-d86fd84d7-2hs4x   0/1     ImagePullBackOff   0          49m
api-service-d86fd84d7-bqpcv   0/1     ErrImagePull       0          49m
api-service-d86fd84d7-ljl2g   0/1     ErrImagePull       0          49m
```

---

### Action Required:
1. Find out why the image can't be pulled
2. Identify the correct image
3. Fix the deployment
4. Verify all 3 replicas come up healthy

---

### Notes:
- This is a new service, rollback = delete deployment
- The intended image is a standard nginx-based API proxy

### SLA: 45 minutes (P2 new service)
