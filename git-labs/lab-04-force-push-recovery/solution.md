# Lab 04: Solution — Force Push Recovery

## Root Cause

A `git reset --hard HEAD~5` moved the branch pointer back 5 commits, then `git push --force` overwrote the remote's history. The commits still exist in the local object store but have no branch reference pointing to them.

## Fix Commands

```bash
cd /tmp/git-lab-04/repo

# Step 1: Find the lost commit in reflog
git reflog
# Look for: "reset: moving from <FULL_SHA> to HEAD~5"
# The FULL_SHA is the original HEAD with all 10 commits

# Step 2: Get the SHA (the one before the reset)
ORIGINAL_HEAD=$(git reflog | grep "reset: moving from" | head -1 | awk '{print $1}')
# Or parse it directly:
ORIGINAL_HEAD=$(git rev-parse 'HEAD@{1}')

# Step 3: Verify it has all 10 commits
git log --oneline "$ORIGINAL_HEAD"
# Should show all 10 feature commits

# Step 4: Restore local
git reset --hard "$ORIGINAL_HEAD"

# Step 5: Verify files are back
ls feature-*.py
# Should show feature-1.py through feature-10.py

# Step 6: Fix the remote
git push --force origin main

# Step 7: Verify remote
git log --oneline origin/main
# Should show all 10 commits
```

## Git Internals Explained

### Why Force Push Is Dangerous

1. `git push --force` replaces the remote's branch pointer unconditionally
2. Other developers who pull after a force push may get conflicts or lost work
3. Unlike local operations, remote reflog is not accessible to regular users

### How Git Stores Commits

- Commits are SHA-1 hashed objects in `.git/objects/`
- Branch names are just files containing a SHA: `.git/refs/heads/main`
- `git reset --hard` moves the branch pointer but DOESN'T delete objects
- Objects become "unreachable" but persist until garbage collection

### Reflog Behavior

- Local reflog: stored in `.git/logs/HEAD` and `.git/logs/refs/heads/<branch>`
- Default expiry: 90 days for unreachable objects
- Bare repos (remotes) have reflog disabled by default (`core.logAllRefUpdates=false`)
- This is why recovery from the remote is usually impossible — you need local reflogs

### Prevention

- Use `git push --force-with-lease` instead (fails if remote was updated by someone else)
- Protect branches in GitHub/GitLab settings
- Enable `core.logAllRefUpdates=true` on bare repos for server-side reflog
- Use `git push --force-if-includes` (Git 2.30+) for even safer force push
