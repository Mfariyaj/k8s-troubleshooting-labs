## Solution: lab-10-audit-log-full

### Root Cause
Audit log device full, blocks all Vault operations

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
