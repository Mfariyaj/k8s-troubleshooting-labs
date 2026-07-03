## Solution: Lab 26

### Root Cause
AKS upgrade stuck: PDB blocking drain, surge maxUnavailable

### Fix (Azure CLI)
```bash
az aks show -n <aks> -g <rg> --query currentKubernetesVersion
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az aks show -n <aks> -g <rg> --query currentKubernetesVersion
# Should now show the correct/working state
```
