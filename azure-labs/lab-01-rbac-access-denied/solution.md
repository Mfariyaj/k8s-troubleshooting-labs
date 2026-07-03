## Solution: Lab 01

### Root Cause
User missing role assignment, can't access Resource Group

### Fix (Azure CLI)
```bash
az role assignment list --assignee <user>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az role assignment list --assignee <user>
# Should now show the correct/working state
```
