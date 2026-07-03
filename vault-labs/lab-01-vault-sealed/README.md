## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Vault in Docker)
2. Set env: `export VAULT_ADDR=http://localhost:8200`
3. Try: `vault status` — observe it's sealed
4. Fix: unseal using the keys
5. Check `solution.md` if stuck. Cleanup: `./cleanup.sh`

---

# Lab 01: Vault Sealed

## Difficulty: ⭐ Easy

## 📚 What This Teaches
When Vault starts, it's in a **sealed** state. It knows WHERE the encrypted data is, but can't read it. You need to provide unseal keys (parts of the master key) to decrypt the data encryption key.

This simulates: Vault server restarted after maintenance, and nobody unsealed it. All applications getting 503 errors.

## 🔧 Scenario
Your application team reports they can't read secrets from Vault. The Vault server was restarted during maintenance window but nobody completed the unseal process.

## 💥 Error Output
```bash
$ vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true      ← PROBLEM: Vault is sealed!
Total Shares       5
Threshold          3
Unseal Progress    0/3
Version            1.15.0

$ vault kv get secret/myapp
Error making API request.
URL: GET http://localhost:8200/v1/secret/data/myapp
Code: 503. Errors:
* Vault is sealed
```

## 💡 Hints

<details><summary>Hint 1</summary>
Check `vault status`. Look at "Sealed" field. If true, Vault can't serve any requests.
</details>

<details><summary>Hint 2</summary>
You need to provide unseal keys. Run `vault operator unseal` and provide a key. You need 3 out of 5 keys (threshold).
</details>

<details><summary>Hint 3</summary>
The unseal keys were generated during `vault operator init`. In dev mode, Vault auto-unseals. In production, you need the actual keys. For this lab, reinitialize: `vault operator init -key-shares=1 -key-threshold=1`
</details>

## 🛠️ Useful Commands
```bash
vault status                          # Check seal state
vault operator init                   # Initialize (first time only)
vault operator unseal <key>           # Provide unseal key
vault operator unseal -key-shares=1 -key-threshold=1  # For dev
vault login <root-token>              # Login after unseal
```

## 📖 Reference
- https://developer.hashicorp.com/vault/docs/concepts/seal
