## Solution: Lab 40

### Root Cause
ADF: linked service auth failed, mapping data flow error

### Fix (Azure CLI)
```bash
az datafactory pipeline-run query-by-factory
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az datafactory pipeline-run query-by-factory
# Should now show the correct/working state
```
