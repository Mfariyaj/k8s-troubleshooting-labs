## Solution: Lab 23

### Root Cause
Azure Disk PVC Pending: wrong StorageClass, AZ mismatch

### Fix (Azure CLI)
```bash
kubectl describe pvc
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
kubectl describe pvc
# Should now show the correct/working state
```
