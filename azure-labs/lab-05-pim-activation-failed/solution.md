## Solution: Lab 05

### Root Cause
PIM eligible role activation fails: justification required

### Fix (Azure CLI)
```bash
az rest --method POST --url 'https://graph.microsoft.com/...'
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az rest --method POST --url 'https://graph.microsoft.com/...'
# Should now show the correct/working state
```
