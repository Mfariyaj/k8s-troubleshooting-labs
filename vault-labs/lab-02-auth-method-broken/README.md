## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Vault in Docker)
2. Set env: `export VAULT_ADDR=http://localhost:8200`
3. Try to access Vault and observe the error
4. Fix the issue using vault CLI
5. Check `solution.md` if stuck. Cleanup: `./cleanup.sh`

---

# lab-02-auth-method-broken

## Scenario
AppRole authentication fails with invalid credentials

## Difficulty: ⭐⭐ Medium

## Expected Error
```
Error: AppRole authentication fails with invalid credentials
```

## Hints
1. Check `vault status` first
2. Check `vault secrets list` or `vault auth list`
3. Read the solution.md for the full fix
