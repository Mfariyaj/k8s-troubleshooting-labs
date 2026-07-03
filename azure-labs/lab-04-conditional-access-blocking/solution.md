## Solution: Lab 04

### Root Cause
CA policy blocking legitimate user login

### Fix (Azure CLI)
```bash
az ad conditional-access policy list
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az ad conditional-access policy list
# Should now show the correct/working state
```
