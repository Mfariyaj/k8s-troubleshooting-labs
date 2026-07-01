# Lab 12 - Helm Secrets Plugin Issues

## Root Cause

The helm-secrets plugin with SOPS encryption has three issues:
1. `.sops.yaml` has wrong `path_regex` - doesn't match the actual secrets file path
2. `SOPS_AGE_KEY_FILE` environment variable is not set or points to wrong location
3. Age key format is incorrect (wrong prefix or malformed key)

## Symptoms

- `helm secrets dec secrets.yaml` fails with "no matching creation rules"
- Decryption fails with "could not find key" or "age: no identity matched"
- Error: "failed to get the data key" when trying to decrypt
- Helm install with secrets plugin fails before template rendering

## Fix Steps

1. Fix `.sops.yaml` path_regex to match your secrets file location
2. Set `SOPS_AGE_KEY_FILE` environment variable to the key file path
3. Ensure the age key file has correct format

## Corrected Configuration

`.sops.yaml`:
```yaml
creation_rules:
  - path_regex: .*secrets.*\.yaml$
    age: >-
      age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
```

Set environment variable:
```bash
export SOPS_AGE_KEY_FILE=~/.sops/age/keys.txt
```

Age key file (`~/.sops/age/keys.txt`) format:
```
# created: 2024-01-01T00:00:00Z
# public key: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
AGE-SECRET-KEY-1QFNZJ7GPFCQXRZ5AGHQVDXQMG4LHYNWJQXDXRH5NG6DVZYFNYLQPG5QHC
```

## Verification

```bash
# Verify SOPS config matches file path
cat .sops.yaml

# Set the key file
export SOPS_AGE_KEY_FILE=~/.sops/age/keys.txt

# Test decryption
sops --decrypt secrets.yaml

# Use with helm-secrets
helm secrets decrypt secrets.yaml

# Install with decrypted secrets
helm secrets install myapp ./mychart -f secrets.yaml
```

## Key Takeaways

- `path_regex` in `.sops.yaml` must match the relative path of your secrets file
- `SOPS_AGE_KEY_FILE` must point to the private key file
- Age private keys start with `AGE-SECRET-KEY-` prefix
- Test decryption with `sops --decrypt` before using helm-secrets
