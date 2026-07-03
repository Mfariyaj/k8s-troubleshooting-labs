## Solution: Lab 49

### Root Cause
ARM template what-if shows unexpected changes

### Fix (Azure CLI)
```bash
az deployment group what-if -g <rg> -f template.json
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az deployment group what-if -g <rg> -f template.json
# Should now show the correct/working state
```
