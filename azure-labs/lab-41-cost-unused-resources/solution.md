## Solution: Lab 41

### Root Cause
Unused disks, unattached NICs, empty App Service Plans

### Fix (Azure CLI)
```bash
az disk list --query '[?managedBy==null]'
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az disk list --query '[?managedBy==null]'
# Should now show the correct/working state
```
