## Solution: Lab 44

### Root Cause
Azure Advisor showing 00/month savings ignored

### Fix (Azure CLI)
```bash
az advisor recommendation list
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az advisor recommendation list
# Should now show the correct/working state
```
