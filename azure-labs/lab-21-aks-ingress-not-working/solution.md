## Solution: Lab 21

### Root Cause
NGINX Ingress/AGIC not creating Azure LB rules

### Fix (Azure CLI)
```bash
kubectl get ingress -A
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
kubectl get ingress -A
# Should now show the correct/working state
```
