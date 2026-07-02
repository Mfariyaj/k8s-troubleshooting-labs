## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 16: Admission Webhook Rejection

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your platform team deployed a ValidatingWebhookConfiguration for pod security scanning
as part of a compliance initiative. Since the webhook went live, NO pods can be created
in the target namespace. The payment-service deployment shows 0/3 replicas ready.
The on-call engineer reports that the webhook service was never actually deployed — the
team only applied the webhook configuration. Production payments are down.

## Symptoms

```bash
$ kubectl get deployments -n lab-16-webhook
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
payment-service   0/3     0            0           5m

$ kubectl get pods -n lab-16-webhook
No resources found in lab-16-webhook namespace.

$ kubectl get replicasets -n lab-16-webhook
NAME                         DESIRED   CURRENT   READY   AGE
payment-service-7f8b9c6d4f   3         0         0       5m
```

## Error Output

```bash
$ kubectl describe replicaset payment-service-7f8b9c6d4f -n lab-16-webhook
...
Events:
  Type     Reason        Age                From                   Message
  ----     ------        ----               ----                   -------
  Warning  FailedCreate  2m (x15 over 5m)   replicaset-controller  Error creating: Internal error occurred: failed calling webhook "validate-pods.security.internal": failed to call webhook: Post "https://pod-security-validator.lab-16-webhook.svc:443/validate-pods?timeout=5s": dial tcp: lookup pod-security-validator.lab-16-webhook.svc.cluster.local: no such host

$ kubectl get events -n lab-16-webhook --field-selector reason=FailedCreate
LAST SEEN   TYPE      REASON        OBJECT                                MESSAGE
30s         Warning   FailedCreate  replicaset/payment-service-7f8b9c6d4f   Error creating: Internal error occurred: failed calling webhook...
```

## Hints

<details>
<summary>Hint 1 (Conceptual)</summary>
The issue involves a ValidatingWebhookConfiguration with failurePolicy: Fail. When the webhook service is unreachable, what happens to the admission request? Check what webhook configurations exist cluster-wide.
</details>

<details>
<summary>Hint 2 (Direction)</summary>
Examine the ValidatingWebhookConfiguration. The webhook points to a service that doesn't exist. The caBundle is also invalid (corrupted base64 cert data). With failurePolicy: Fail, unreachable webhooks will reject ALL matching requests. Consider the namespaceSelector too — it's scoped to a specific label.
</details>

<details>
<summary>Hint 3 (Solution Path)</summary>
Fix options: (1) Change failurePolicy from "Fail" to "Ignore" temporarily, (2) Delete the ValidatingWebhookConfiguration entirely, (3) Create the missing webhook service and fix the caBundle. The fastest production fix is to delete or patch the webhook config, then redeploy the payment-service pods.
</details>

## Troubleshooting Commands

```bash
# Check webhook configurations cluster-wide
kubectl get validatingwebhookconfigurations

# Describe the webhook configuration
kubectl describe validatingwebhookconfiguration pod-security-validator.lab-16-webhook.svc

# Check if the webhook service exists
kubectl get svc -n lab-16-webhook

# Look at ReplicaSet events
kubectl describe rs -n lab-16-webhook

# Check deployment status
kubectl get deployment payment-service -n lab-16-webhook -o yaml

# Look at namespace labels (used by namespaceSelector)
kubectl get namespace lab-16-webhook --show-labels

# Check events in the namespace
kubectl get events -n lab-16-webhook --sort-by='.lastTimestamp'

# Try creating a test pod directly to confirm webhook blocks it
kubectl run test-pod --image=nginx -n lab-16-webhook --dry-run=server

# Check API server logs for webhook failures (if access available)
kubectl logs -n kube-system -l component=kube-apiserver --tail=50

# Decode and inspect the caBundle
kubectl get validatingwebhookconfiguration pod-security-validator.lab-16-webhook.svc -o jsonpath='{.webhooks[0].clientConfig.caBundle}' | base64 -d

# Check the failurePolicy
kubectl get validatingwebhookconfiguration pod-security-validator.lab-16-webhook.svc -o jsonpath='{.webhooks[0].failurePolicy}'

# List all services in the namespace to confirm webhook service is missing
kubectl get endpoints -n lab-16-webhook
```

## Expected Resolution Time: 15-30 minutes

## What You'll Learn

- How ValidatingWebhookConfigurations intercept API requests
- The critical difference between failurePolicy: Fail vs Ignore
- How namespaceSelector scopes webhook impact
- Production incident response for misconfigured admission controllers
- The importance of deploying webhook services before their configurations
