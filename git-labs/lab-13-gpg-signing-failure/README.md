## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a local git repo with the broken state)
2. Navigate: `cd /tmp/git-lab-XX/`
3. Investigate: `git status`, `git log --oneline`, `git reflog`
4. Fix the issue using git commands
5. Verify your fix resolves the problem
6. Check `solution.md` if stuck. Cleanup: `./cleanup.sh`

---

# Lab 13: GPG Signing Failure

## Difficulty: 🔴 Advanced

## Scenario

Your team has mandated commit signing. The git configuration has been set up, but it's broken:
1. `gpg.program` points to `/usr/local/bin/gpg-nonexistent` (wrong path)
2. `user.signingkey` is set to `DEADBEEF12345678` (key doesn't exist)
3. `commit.gpgsign` is `true` (forces signing on every commit)

You have a staged file (`feature.py`) that you cannot commit because every commit attempt fails with GPG errors.

## What You'll See

```bash
$ cd /tmp/git-lab-13
$ git commit -m "add feature"
error: gpg failed to sign the data
fatal: failed to write commit object

$ git config --list --local | grep -i sign
commit.gpgsign=true
user.signingkey=DEADBEEF12345678
gpg.program=/usr/local/bin/gpg-nonexistent
```

## Hints

1. **Hint 1**: You have three options: (a) fix the gpg path to the real gpg binary, (b) disable signing, or (c) commit with `--no-gpg-sign` as a one-time bypass. Option (a) requires having a GPG key.

2. **Hint 2**: To find the real gpg binary: `which gpg` or `which gpg2`. To fix: `git config gpg.program $(which gpg)`. To disable signing: `git config commit.gpgsign false`.

3. **Hint 3**: To properly fix everything and sign commits: fix the gpg program path, then either generate a new key (`gpg --full-generate-key`) or list existing keys (`gpg --list-secret-keys`), then set the correct signing key.

## Useful Commands

```bash
git config --list --show-origin     # All config with file locations
git config commit.gpgsign false     # Disable signing
git config --unset gpg.program      # Remove custom gpg path
git config --unset user.signingkey  # Remove signing key
git commit --no-gpg-sign -m "msg"   # One-time bypass
which gpg                           # Find real gpg binary
gpg --list-secret-keys --keyid-format=long  # List available keys
gpg --full-generate-key             # Create new key
git log --show-signature            # Verify signed commits
```

## Success Criteria

- You can successfully commit `feature.py`
- The commit is created (visible in `git log`)
- Git configuration is consistent (no errors on subsequent commits)
- Bonus: commit is actually GPG-signed and verifiable
