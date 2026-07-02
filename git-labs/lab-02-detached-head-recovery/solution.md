# Lab 02: Solution — Detached HEAD Recovery

## Root Cause

When you checkout a specific commit hash (not a branch), Git enters "detached HEAD" state. Any commits made in this state are not associated with any branch. When you switch back to a named branch, those commits become "orphaned" — they exist in the object database but no reference points to them.

## Fix Commands

```bash
cd /tmp/git-lab-02

# Step 1: Use reflog to find the lost commits
git reflog
# Look for entries like:
# abc1234 HEAD@{1}: checkout: moving from abc1234 to main
# abc1234 HEAD@{2}: commit: IMPORTANT: added monitoring to hotfix
# def5678 HEAD@{3}: commit: IMPORTANT: emergency hotfix for production v2

# Step 2: Identify the latest lost commit SHA
# It's the one just before "checkout: moving from ... to main"
LOST_SHA=$(git reflog | grep "IMPORTANT: added monitoring" | head -1 | awk '{print $1}')

# Step 3: Create a branch at that commit
git branch hotfix-recovery "$LOST_SHA"

# Step 4: Verify
git log --oneline hotfix-recovery
# Should show both IMPORTANT commits plus the history before them

# Alternative: use git fsck
git fsck --lost-found
# Lists dangling commits — same SHAs visible here
```

## Git Internals Explained

### How Detached HEAD Works

1. **Normal state**: HEAD points to a branch ref (e.g., `refs/heads/main`), which points to a commit.
2. **Detached state**: HEAD points directly to a commit SHA, bypassing branch refs.
3. **What `.git/HEAD` contains**:
   - Normal: `ref: refs/heads/main`
   - Detached: `abc123def456...` (raw SHA)

### Why Commits Aren't Lost

- Every commit is a Git object stored in `.git/objects/`
- Objects are only removed by `git gc` after they're unreachable AND older than the reflog expiry (default: 90 days for unreachable, 30 days for reachable)
- The reflog (`git reflog`) records every HEAD movement for 90 days by default

### Recovery Methods (in order of preference)

1. **`git reflog`**: Best method — shows exact SHAs with timestamps
2. **`git fsck --lost-found`**: Finds all unreachable objects
3. **`git log -g`**: Same as reflog but with full log format
4. **`.git/logs/HEAD`**: Raw reflog file (last resort)

### Prevention

- Always create a branch before making commits: `git checkout -b hotfix HEAD~3`
- Use `git switch -c <branch> <commit>` instead of `git checkout <commit>`
- Git warns about detached HEAD — read the warning!
