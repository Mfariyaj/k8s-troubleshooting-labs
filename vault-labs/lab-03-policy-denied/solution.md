## Solution: lab-03-policy-denied

### Root Cause
Policy denies access to required secret path

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
