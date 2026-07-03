## Solution: Lab 28

### Root Cause
Function timeout: wrong binding, input trigger config

### Fix (Azure CLI)
```bash
az functionapp show -n <func> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az functionapp show -n <func> -g <rg>
# Should now show the correct/working state
```
