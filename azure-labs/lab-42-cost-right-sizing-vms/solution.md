## Solution: Lab 42

### Root Cause
D4s_v3 running at 3% CPU, should be B2s

### Fix (Azure CLI)
```bash
az advisor recommendation list --category Cost
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az advisor recommendation list --category Cost
# Should now show the correct/working state
```
