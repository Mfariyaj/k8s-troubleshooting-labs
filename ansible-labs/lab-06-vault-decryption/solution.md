## Solution: Vault Decryption Failure

### Root Cause

Vault decryption fails due to:
1. **Wrong vault password file path** in ansible.cfg — points to nonexistent file
2. **Incorrect password** — vault encrypted with one password but another is configured
3. **Inconsistent encryption** — some files encrypted with different passwords

### Step-by-Step Fix

1. **Identify the correct password file:**
```bash
ls -la vault_pass*.txt .vault_pass
```

2. **Fix vault_password_file in ansible.cfg:**
```ini
[defaults]
vault_password_file = ./vault_pass_correct.txt
```

3. **Re-encrypt vault files with consistent password:**
```bash
ansible-vault rekey vault.yml \
  --old-vault-password-file=vault_pass_old.txt \
  --new-vault-password-file=vault_pass_correct.txt

ansible-vault rekey group_vars/all/vault.yml \
  --old-vault-password-file=vault_pass_old.txt \
  --new-vault-password-file=vault_pass_correct.txt
```

### Fixed Configuration

**ansible.cfg:**
```ini
[defaults]
inventory = inventory.ini
vault_password_file = ./vault_pass_correct.txt
```

### Verification

```bash
# Test vault decryption
ansible-vault view vault.yml
# Should display decrypted content without errors

# Run the playbook
ansible-playbook playbook.yml -v

# Verify all vault files decrypt properly
ansible-vault view group_vars/all/vault.yml
```

### Key Takeaway

Use a consistent vault password across all encrypted files. Store the password
file path in ansible.cfg and ensure the file exists. Use `ansible-vault rekey`
to migrate files to a new password.
