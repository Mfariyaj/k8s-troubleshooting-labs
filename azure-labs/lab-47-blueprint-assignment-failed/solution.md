## Solution: Lab 47

### Root Cause
Blueprint conflicts with existing resource configurations

### Fix (Azure CLI)
```bash
az blueprint assignment list
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az blueprint assignment list
# Should now show the correct/working state
```
