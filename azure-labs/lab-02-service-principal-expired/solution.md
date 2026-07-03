## Solution: Lab 02

### Root Cause
Service Principal client secret expired, app auth fails

### Fix (Azure CLI)
```bash
az ad sp credential list --id <app-id>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az ad sp credential list --id <app-id>
# Should now show the correct/working state
```
