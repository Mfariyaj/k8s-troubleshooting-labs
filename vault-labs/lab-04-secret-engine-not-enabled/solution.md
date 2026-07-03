## Solution: lab-04-secret-engine-not-enabled

### Root Cause
KV secret engine not mounted at expected path

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
