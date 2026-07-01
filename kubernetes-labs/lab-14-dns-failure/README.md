# 🎫 INCIDENT TICKET - INC-4847

## Priority: P1 - Critical | Assignee: You | Team: Platform Engineering

---

### Title: [PROD] api-gateway DNS resolution failing - can't discover user-service internally

### Reporter: Pooja Sharma (Microservices Lead)
### Created: 2026-07-01 12:30 IST
### Environment: Production (lab-14 namespace)

---

### Description:

The `api-gateway` pod cannot resolve internal Kubernetes service names. It's trying to reach `user-service` but DNS lookups fail. The gateway logs show "Could not resolve host" errors.

Strange thing: the `user-service` pods are running fine, and other pods in the cluster can resolve DNS normally. This seems specific to the api-gateway pod's DNS configuration.

---

### What we know:
- `api-gateway` pod is Running but can't resolve internal DNS
- `user-service` pods are Running and the Service exists
- Other pods in other namespaces have no DNS issues
- The api-gateway pod was configured with a custom `dnsPolicy` and `dnsConfig`
- Someone on the networking team set `dnsPolicy: "None"` with external DNS (8.8.8.8)
- Google DNS (8.8.8.8) can't resolve `user-service.lab-14.svc.cluster.local`!
- Also: The service is named `users-svc` not `user-service` (naming mismatch)

---

### Observations from on-call:
```
$ kubectl get pods -n lab-14
NAME                            READY   STATUS    RESTARTS   AGE
api-gateway-546d8d6d6-f6djc    1/1     Running   0          49m
user-service-85979bdf76-mcv66   1/1     Running   0          49m
user-service-85979bdf76-pq97t   1/1     Running   0          49m

$ kubectl get svc -n lab-14
NAME              TYPE        CLUSTER-IP      PORT(S)    AGE
api-gateway-svc   ClusterIP   10.96.x.x      80/TCP     49m
users-svc         ClusterIP   10.96.x.x      8080/TCP   49m

$ kubectl exec -n lab-14 api-gateway-546d8d6d6-f6djc -- nslookup user-service
** server can't find user-service: NXDOMAIN

$ kubectl exec -n lab-14 api-gateway-546d8d6d6-f6djc -- cat /etc/resolv.conf
nameserver 8.8.8.8           ← WRONG! Should be cluster DNS (10.96.0.10)
search lab-14.svc.cluster.local
```

---

### Action Required:
1. Identify why the pod uses 8.8.8.8 instead of cluster DNS (check dnsPolicy)
2. Fix the dnsPolicy (remove `dnsPolicy: None` or change to `ClusterFirst`)
3. Also notice: the code calls `user-service` but the Service name is `users-svc`
4. Fix BOTH issues: DNS config AND service name mismatch
5. Verify: `kubectl exec <api-gateway> -- nslookup users-svc` works

---

### Two bugs here:
- **Bug 1**: dnsPolicy: None → uses 8.8.8.8 → can't resolve cluster-internal names
- **Bug 2**: Code references `user-service` but service is named `users-svc`

### SLA: 20 minutes (P1 inter-service communication broken)
