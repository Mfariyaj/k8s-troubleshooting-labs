# Lab 12: Helm Secrets Plugin — SOPS Decryption Failures

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your production deployment pipeline uses `helm-secrets` with SOPS to encrypt sensitive values (database passwords, API keys, JWT secrets). The pipeline was working last month, but after a team rotation, new engineers regenerated keys and updated the encrypted files. Now the entire secrets pipeline is broken — decryption fails with confusing errors about key formats, mismatched recipients, and path regex rules.

## What You'll Observe

```
$ helm secrets install myapp ./mychart -f secrets.yaml --namespace lab12-secrets --create-namespace
[helm-secrets] Decrypt: secrets.yaml
[helm-secrets] Error: Failed to decrypt secrets.yaml
Error: error decrypting key: no matching keys found in SOPS config

$ # After investigating .sops.yaml:
[helm-secrets] Error: Failed to get the data key required to decrypt the SOPS file.
Group 0: FAILED
  age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p: FAILED
    - | error decrypting with age: no identity matched any recipient
  1234567890ABCDEF1234567890ABCDEF12345678: FAILED
    - | could not decrypt data key with PGP key: gpg: decryption failed: No secret key

$ # After fixing key issues:
Error: plugin "secrets" exited with error
  Could not generate the age identity: malformed secret key

$ # Environment variable check:
$ echo $SOPS_AGE_KEY_FILE
  (empty — not set)
```

## Your Task

Fix all issues with the helm-secrets integration so that:
1. `.sops.yaml` path_regex matches the actual secrets file
2. The correct age key is used for decryption
3. The SOPS_AGE_KEY_FILE environment variable points to a valid key
4. The encrypted file uses a consistent encryption format
5. The helm-secrets plugin version is compatible

## Hints

<details>
<summary>Hint 1</summary>
The `.sops.yaml` file has a `path_regex` that expects files matching `secrets/*.enc.yaml` but the actual file is just `secrets.yaml` in the current directory. The regex must match the file's path relative to `.sops.yaml`. Also check if the second rule has a recipient key (public key) vs a secret key in the age field.
</details>

<details>
<summary>Hint 2</summary>
SOPS age decryption requires `SOPS_AGE_KEY_FILE` to point to a file containing the private key (starts with `AGE-SECRET-KEY-`). The `.sops.yaml` creation_rules should contain the public key (starts with `age1...`), not the secret key. Check if the two are swapped somewhere.
</details>

<details>
<summary>Hint 3</summary>
The encrypted file `secrets.yaml` has both `age` and `pgp` sections in its SOPS metadata. SOPS uses an OR logic for groups — it tries each key provider. If the PGP key is expired/missing and the age key doesn't match, decryption fails. The age recipient in the encrypted file must match the public key derived from your private key. Re-encrypt with just age if PGP is unavailable.
</details>

## Commands to Help Diagnose

```bash
# Check if helm-secrets plugin is installed
helm plugin list
helm plugin install https://github.com/jkroepke/helm-secrets --version v4.5.1

# Check SOPS version
sops --version

# Try decrypting directly with sops
sops -d secrets.yaml

# Check what keys SOPS is looking for
sops -d --verbose secrets.yaml

# Inspect the encrypted file's SOPS metadata
cat secrets.yaml | grep -A 50 "^sops:"

# Check .sops.yaml rules
cat .sops.yaml

# Verify age key environment
echo $SOPS_AGE_KEY_FILE
cat $SOPS_AGE_KEY_FILE 2>/dev/null || echo "Key file not found or not set"

# Generate a new age key pair
age-keygen -o key.txt
cat key.txt | grep "public key:" 

# Test path_regex matching
echo "secrets.yaml" | grep -P 'secrets/.*\.enc\.yaml$'
echo "secrets.yaml" | grep -P '\.yaml$'

# Check helm-secrets plugin version compatibility
helm secrets --help
helm plugin list | grep secrets

# Re-encrypt with correct key
sops --encrypt --age age1... --in-place secrets.yaml

# Decrypt and view (debug)
sops --decrypt secrets.yaml
```

## What You'll Learn

- How SOPS encryption/decryption works with multiple key providers
- The relationship between `.sops.yaml` creation_rules and file matching
- Age key pairs (public recipient vs private identity)
- helm-secrets plugin architecture and SOPS integration
- Debugging key management issues in GitOps pipelines
