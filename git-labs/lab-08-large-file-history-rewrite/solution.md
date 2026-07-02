# Lab 08: Solution — Large File History Rewrite

## Root Cause

Git stores all versions of all files ever committed. Even after `git rm`, historical commits still contain the file as a blob object. The pack file includes all objects, so the repo remains large.

## Fix Commands

### Method 1: git filter-branch (available everywhere)

```bash
cd /tmp/git-lab-08

# Rewrite history to remove the file from all commits
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch database_dump.sql' \
  --prune-empty -- --all

# Remove the backup refs created by filter-branch
rm -rf .git/refs/original/

# Expire reflog (so old commits become unreachable)
git reflog expire --expire=now --all

# Garbage collect to actually delete the objects
git gc --prune=now --aggressive

# Verify
du -sh .git          # Should be ~100KB now
git rev-list --objects --all | grep database_dump  # Should return nothing
```

### Method 2: git filter-repo (recommended, if installed)

```bash
cd /tmp/git-lab-08

# Install if needed: pip install git-filter-repo
git filter-repo --path database_dump.sql --invert-paths

# That's it! filter-repo handles cleanup automatically.
du -sh .git
```

### Method 3: BFG Repo-Cleaner (if installed)

```bash
cd /tmp/git-lab-08

# java -jar bfg.jar --delete-files database_dump.sql .
# git reflog expire --expire=now --all && git gc --prune=now
```

## Git Internals Explained

### Git Object Storage

```
commit → tree → blob (file content)
                     ↑
         This blob (50MB) exists even if later commits don't reference it.
         It lives in .git/objects/pack/*.pack
```

### Why Simple `git rm` Doesn't Work

- `git rm` creates a new commit where the file is gone from the tree
- But the old commit still has a tree → blob reference
- When you clone, you download ALL objects including historical ones
- `git gc` won't clean it because it's still reachable via old commits

### What filter-branch Does

1. Walks through EVERY commit in history
2. For each commit, applies the filter (remove the file from the index)
3. Creates a new commit with the modified tree
4. Rewrites all branch and tag refs to point to new commits
5. Old commits become unreachable (but still exist until gc)

### Size Verification Chain

```bash
# 1. Check objects are gone
git rev-list --objects --all | grep database_dump

# 2. Check pack file size  
git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -5

# 3. Check total .git size
du -sh .git

# 4. Force repack
git repack -ad
```

### Prevention

- Add large file patterns to `.gitignore` BEFORE they can be committed
- Use `git lfs` for files that must be tracked
- Set up pre-commit hooks to reject files over a size threshold
- Use GitHub's push size limits as safety net
