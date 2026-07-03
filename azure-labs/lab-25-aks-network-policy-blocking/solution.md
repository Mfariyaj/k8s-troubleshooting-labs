## Solution: Lab 25

### Root Cause
Azure Network Policy blocking pod-to-pod traffic

### Fix (Azure CLI)
```bash
kubectl get networkpolicies -A
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
kubectl get networkpolicies -A
# Should now show the correct/working state
```
