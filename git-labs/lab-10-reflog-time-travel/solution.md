# Lab 10: Solution — Reflog Time Travel

## Root Cause

`git reset --hard HEAD~5` does three things:
1. Moves the branch pointer back 5 commits
2. Updates the index to match the new HEAD
3. Updates the working tree to match the index

This effectively "erases" the last 5 commits from the branch, but they still exist as objects in `.git/objects/`.

## Fix Commands

```bash
cd /tmp/git-lab-10

# Method 1: Use reflog notation (simplest)
git reset --hard HEAD@{1}

# Method 2: Find SHA from reflog and use directly
git reflog
# Find the entry like: abc1234 HEAD@{1}: commit: feat: add module 10
SHA=$(git reflog | grep "feat: add module 10" | head -1 | awk '{print $1}')
git reset --hard "$SHA"

# Method 3: Non-destructive — create a recovery branch first
git branch recovery HEAD@{1}
git merge recovery    # Fast-forward merge
git branch -d recovery

# Verify
git log --oneline | wc -l    # Should be 10
ls module_*.py | wc -l       # Should be 10
```

## Git Internals Explained

### What `reset --hard` Actually Does

```
Before:  main → commit10 → commit9 → ... → commit1
After:   main → commit5 → ... → commit1
         (commits 6-10 still exist, just unreachable from any ref)
```

### The Reflog Safety Net

- Every HEAD movement is recorded in `.git/logs/HEAD`
- Format: `<old-sha> <new-sha> <author> <timestamp> <message>`
- Default expiry: 90 days for reachable, 30 days for unreachable
- `HEAD@{n}` = what HEAD pointed to n operations ago
- `main@{n}` = what main pointed to n operations ago

### Reflog vs. Log

| | `git log` | `git reflog` |
|-|-----------|-------------|
| Shows | Commit ancestry (reachable from HEAD) | All HEAD positions (including orphaned) |
| After reset | Only shows current history | Shows both before AND after reset |
| Survives clone | Yes | No (per-repo only) |

### When Reflog Won't Help

- After `git reflog expire --expire=now --all` (manually expired)
- After `git gc --prune=now` (garbage collected unreachable objects)
- On a fresh clone (reflog is local-only)
- After 90 days (default expiry)
- On bare repos (reflog disabled by default)

### Prevention

- Think twice before `--hard` — use `--soft` or `--mixed` to keep changes staged/unstaged
- Use `git stash` before destructive operations
- Set up branch protection rules
- Use `git reset --keep` — refuses if uncommitted changes would be overwritten
