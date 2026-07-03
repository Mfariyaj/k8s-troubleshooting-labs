## Solution: Lab 15

### Root Cause
Site-to-Site VPN tunnel down: shared key mismatch

### Fix (Azure CLI)
```bash
az network vpn-connection show -n <conn> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az network vpn-connection show -n <conn> -g <rg>
# Should now show the correct/working state
```
