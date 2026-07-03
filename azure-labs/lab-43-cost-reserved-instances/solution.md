## Solution: Lab 43

### Root Cause
RI recommendation: wrong VM family reserved

### Fix (Azure CLI)
```bash
az consumption reservation summary list
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az consumption reservation summary list
# Should now show the correct/working state
```
