## Solution: Lab 48

### Root Cause
CanNotDelete lock preventing resource modification

### Fix (Azure CLI)
```bash
az lock list -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az lock list -g <rg>
# Should now show the correct/working state
```
