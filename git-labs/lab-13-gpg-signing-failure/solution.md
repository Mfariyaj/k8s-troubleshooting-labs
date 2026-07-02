# Lab 13: Solution — GPG Signing Failure

## Root Cause

Three configuration issues:
1. `gpg.program` = `/usr/local/bin/gpg-nonexistent` — binary doesn't exist
2. `user.signingkey` = `DEADBEEF12345678` — no such key in GPG keyring
3. `commit.gpgsign` = `true` — forces signing (so you can't just not sign)

## Fix Commands

### Approach A: Disable Signing (Quick Fix)

```bash
cd /tmp/git-lab-13

# Remove all signing config
git config --unset commit.gpgsign
git config --unset user.signingkey
git config --unset gpg.program

# Commit works now
git commit -m "add feature"
```

### Approach B: Fix GPG Path + Bypass Key (Medium Fix)

```bash
cd /tmp/git-lab-13

# Fix GPG program path
git config gpg.program "$(which gpg 2>/dev/null || which gpg2 2>/dev/null)"

# Disable mandatory signing (but allow optional --gpg-sign)
git config commit.gpgsign false
git config --unset user.signingkey

# Commit without signing
git commit -m "add feature"
```

### Approach C: Full Fix with Real Key (Proper Solution)

```bash
cd /tmp/git-lab-13

# Fix GPG program
git config gpg.program "$(which gpg)"

# Generate a new key (non-interactive)
cat > /tmp/gpg-params <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Lab User
Name-Email: dev@example.com
Expire-Date: 1y
%commit
EOF
gpg --batch --gen-key /tmp/gpg-params

# Get the key ID
KEY_ID=$(gpg --list-secret-keys --keyid-format=long dev@example.com | grep "sec" | head -1 | awk -F'/' '{print $2}' | awk '{print $1}')

# Set the signing key
git config user.signingkey "$KEY_ID"

# Commit (now properly signed)
git commit -m "add feature"

# Verify
git log --show-signature -1
```

### Approach D: One-Time Bypass

```bash
cd /tmp/git-lab-13

# Commit just this once without signing
git commit --no-gpg-sign -m "add feature"

# This bypasses all GPG config for a single commit
# Not a real fix, but useful in emergencies
```

## Git Internals Explained

### How Git GPG Signing Works

1. Git calls the `gpg.program` binary to create a signature
2. The signature is embedded in the commit object as a header
3. Verification uses the public key to check the signature
4. Signed commit object format includes a `gpgsig` header

### Commit Object Structure (Signed)

```
tree <sha>
parent <sha>
author Lab User <dev@example.com> 1234567890 +0000
committer Lab User <dev@example.com> 1234567890 +0000
gpgsig -----BEGIN PGP SIGNATURE-----
 [base64 signature data]
 -----END PGP SIGNATURE-----

Commit message here
```

### Configuration Precedence

```
1. Command-line flags (--no-gpg-sign, -S<keyid>)
2. Repo .git/config (git config --local)
3. ~/.gitconfig (git config --global)
4. /etc/gitconfig (git config --system)
```

### Alternative: SSH Signing (Git 2.34+)

```bash
git config gpg.format ssh
git config user.signingkey ~/.ssh/id_ed25519.pub
git config gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
# No GPG needed!
```

### Troubleshooting GPG

```bash
# Test GPG independently
echo "test" | gpg --clearsign
# If this fails, it's a GPG problem, not a Git problem

# Check GPG agent
gpgconf --kill gpg-agent
gpg-agent --daemon

# Verbose signing attempt
GIT_TRACE=1 git commit -m "test"
```
