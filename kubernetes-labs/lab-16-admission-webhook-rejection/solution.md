## Solution: Admission Webhook Rejection

### Root Cause

The ValidatingWebhookConfiguration has:
1. An invalid `caBundle` (corrupted base64 certificate data)
2. References a service `pod-security-validator` in namespace `lab-16-webhook` that doesn't exist
3. `failurePolicy: Fail` means any webhook communication failure rejects pod creation

All pod CREATE operations in the labeled namespace are blocked.

### Diagnosis

```bash
kubectl get pods -n lab-16-webhook
kubectl describe deployment payment-service -n lab-16-webhook
kubectl get events -n lab-16-webhook --sort-by='.lastTimestamp'
kubectl get validatingwebhookconfiguration
```

Events show: `failed calling webhook "validate-pods.security.internal": connection refused` or TLS errors.

### Fix

Option 1 (quickest): Change failurePolicy to Ignore:

```bash
kubectl edit validatingwebhookconfiguration pod-security-validator.lab-16-webhook.svc
```

Change `failurePolicy: Fail` to `failurePolicy: Ignore`

Option 2: Delete the webhook entirely:

```bash
kubectl delete validatingwebhookconfiguration pod-security-validator.lab-16-webhook.svc
```

Then restart the deployment:

```bash
kubectl rollout restart deployment payment-service -n lab-16-webhook
```

### Fixed YAML (Option 1 - change failurePolicy)

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: pod-security-validator.lab-16-webhook.svc
spec:
  webhooks:
    - name: validate-pods.security.internal
      admissionReviewVersions: ["v1", "v1beta1"]
      sideEffects: None
      failurePolicy: Ignore
      timeoutSeconds: 5
      clientConfig:
        service:
          name: pod-security-validator
          namespace: lab-16-webhook
          path: /validate-pods
          port: 443
        caBundle: ""
      rules:
        - apiGroups: [""]
          apiVersions: ["v1"]
          operations: ["CREATE"]
          resources: ["pods"]
          scope: "Namespaced"
      namespaceSelector:
        matchLabels:
          lab: webhook-rejection
```

### Verification

```bash
kubectl get pods -n lab-16-webhook
# Pods should now be created and Running
kubectl get events -n lab-16-webhook --sort-by='.lastTimestamp' | tail -5
```
