## Solution: Lab 29

### Root Cause
Slot swap stuck: connection string slot setting

### Fix (Azure CLI)
```bash
az webapp deployment slot list -n <app> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az webapp deployment slot list -n <app> -g <rg>
# Should now show the correct/working state
```
