## Solution: Lab 16

### Root Cause
Azure Firewall application rule blocking HTTPS traffic

### Fix (Azure CLI)
```bash
az network firewall application-rule list -g <rg> -f <fw>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az network firewall application-rule list -g <rg> -f <fw>
# Should now show the correct/working state
```
