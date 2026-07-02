# Lab 12: Solution — Worktree Corruption

## Root Cause

Three separate issues:
1. Auth worktree was rm -rf'd, leaving metadata in `.git/worktrees/` pointing to non-existent directory
2. Api branch ref was deleted, and worktree gitdir path is corrupted
3. Dashboard worktree directory deleted, metadata stale

## Fix Commands

```bash
cd /tmp/git-lab-12

# Step 1: Check what branches and commits still exist
git branch -a
# feature-auth and feature-dashboard should still exist
# feature-api was deleted

# Step 2: Recover the api branch commit
# Check the worktree's HEAD file
cat .git/worktrees/git-lab-12-worktree-api/HEAD
# If this shows a SHA, use it. If it says "ref: refs/heads/feature-api", check reflog:
API_SHA=$(git reflog | grep "feature-api" | head -1 | awk '{print $1}')
# Or from the HEAD file in worktree metadata:
# API_SHA=$(cat .git/worktrees/git-lab-12-worktree-api/HEAD)

# Recreate the api branch
git branch feature-api "$API_SHA" 2>/dev/null || \
  git branch feature-api $(cat .git/worktrees/git-lab-12-worktree-api/HEAD)

# Step 3: Prune stale worktree entries
git worktree prune

# Step 4: Verify cleanup
git worktree list
# Should only show the main worktree

ls .git/worktrees/
# Should be empty or the directory shouldn't exist

# Step 5: Verify all branch work is preserved
git log --oneline feature-auth   # Should show "Add auth module"
git log --oneline feature-api    # Should show "Add API module"
git log --oneline feature-dashboard  # Should show "Add dashboard module"

# Step 6: Optionally, recreate worktrees properly
git worktree add /tmp/git-lab-12-worktree-auth feature-auth
git worktree add /tmp/git-lab-12-worktree-api feature-api
git worktree add /tmp/git-lab-12-worktree-dashboard feature-dashboard
```

## Git Internals Explained

### How Worktrees Work

```
Main repo: /tmp/git-lab-12/
  .git/                              # Main git directory
  .git/worktrees/                    # Metadata for linked worktrees
  .git/worktrees/<name>/HEAD         # What commit the worktree is at
  .git/worktrees/<name>/gitdir       # Path to .git file in worktree
  .git/worktrees/<name>/commondir    # Points back to main .git
  .git/worktrees/<name>/locked       # Lock file (prevents pruning)

Worktree: /tmp/git-lab-12-worktree-auth/
  .git                               # FILE (not dir!) pointing to main repo
  # Contains: gitdir: /tmp/git-lab-12/.git/worktrees/git-lab-12-worktree-auth
```

### Worktree Prune Logic

`git worktree prune` removes entries from `.git/worktrees/<name>/` when:
- The `gitdir` path doesn't exist (worktree directory deleted)
- The path exists but isn't a valid git worktree
- NOT if a `.git/worktrees/<name>/locked` file exists

### Worktree vs. Multiple Clones

| Feature | Worktree | Clone |
|---------|----------|-------|
| Disk space | Shared objects | Full copy |
| Branch lock | Can't checkout same branch in two worktrees | No restriction |
| Reflog | Shared | Separate |
| Stash | Shared | Separate |

### Prevention

- Always use `git worktree remove <path>` instead of `rm -rf`
- Use `git worktree lock <path>` to prevent accidental pruning
- Don't delete branches that have active worktrees
- Run `git worktree list` periodically to audit
