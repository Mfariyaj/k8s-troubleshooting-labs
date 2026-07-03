## Solution: Lab 50

### Root Cause
Terraform AzureRM provider state lock conflict

### Fix (Azure CLI)
```bash
terraform force-unlock <id>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
terraform force-unlock <id>
# Should now show the correct/working state
```
