## Solution: Lab 45

### Root Cause
Resources not compliant with org policies

### Fix (Azure CLI)
```bash
az policy state list --filter 'complianceState eq NonCompliant'
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az policy state list --filter 'complianceState eq NonCompliant'
# Should now show the correct/working state
```
