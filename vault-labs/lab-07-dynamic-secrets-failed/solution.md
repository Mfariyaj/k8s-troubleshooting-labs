## Solution: lab-07-dynamic-secrets-failed

### Root Cause
Database dynamic secrets role cannot connect

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
