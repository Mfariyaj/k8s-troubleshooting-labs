## Solution: lab-05-token-expired

### Root Cause
Token TTL expired and cannot be renewed

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
