## Solution: Lab 09

### Root Cause
VM in VNet can't reach internet: no NAT Gateway/Public IP

### Fix (Azure CLI)
```bash
az network nic show-effective-route-table
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az network nic show-effective-route-table
# Should now show the correct/working state
```
