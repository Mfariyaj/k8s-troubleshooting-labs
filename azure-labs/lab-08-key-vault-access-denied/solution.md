## Solution: Lab 08

### Root Cause
Key Vault RBAC vs Access Policy mode conflict

### Fix (Azure CLI)
```bash
az keyvault show -n <kv> --query properties.enableRbacAuthorization
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az keyvault show -n <kv> --query properties.enableRbacAuthorization
# Should now show the correct/working state
```
