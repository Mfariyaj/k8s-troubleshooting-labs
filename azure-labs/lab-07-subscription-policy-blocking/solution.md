## Solution: Lab 07

### Root Cause
Azure Policy denying VM creation: allowed SKUs policy

### Fix (Azure CLI)
```bash
az policy assignment list
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az policy assignment list
# Should now show the correct/working state
```
