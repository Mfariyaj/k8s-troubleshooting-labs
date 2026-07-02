# Lab 08: Large File History Rewrite

## Difficulty: 🔴 Advanced

## Scenario

Someone accidentally committed a 50MB `database_dump.sql` to the repo. Although it was deleted in a later commit, it's still bloating the repository history. Every clone downloads 50MB+ of data because that file exists in a historical tree object.

You need to completely remove it from ALL Git history — not just the current tree.

## What You'll See

```bash
$ cd /tmp/git-lab-08
$ du -sh .git
52M     .git

$ git log --oneline --stat
abc1234 feat: connect to database
def5678 chore: remove database dump (file too large)
ghi9012 feat: add configuration module
jkl3456 feat: add version function
mno7890 feat: added database dump for seeding (ACCIDENT - 50MB!)
 database_dump.sql | Bin 0 -> 52428800 bytes
pqr1234 Initial commit

$ git rev-list --objects --all | grep database_dump
abc1234 database_dump.sql     # Still in object store!
```

## Hints

1. **Hint 1**: `git rm` only removes from the working tree and future commits. To remove from history, you need `git filter-branch` or the newer `git filter-repo` (recommended). Without `git-filter-repo`, you can use `git filter-branch --index-filter`.

2. **Hint 2**: The command: `git filter-branch --index-filter 'git rm --cached --ignore-unmatch database_dump.sql' --prune-empty -- --all` rewrites all commits to exclude the file.

3. **Hint 3**: After filter-branch, you must also: (a) delete the backup refs, (b) expire the reflog, and (c) run `git gc --prune=now` to actually reclaim space. Check with `du -sh .git` afterward.

## Useful Commands

```bash
git rev-list --objects --all        # List all objects
git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail  # Largest objects
git log --oneline --all -- database_dump.sql    # Commits touching the file
git filter-branch --index-filter '...' --all    # Rewrite history
git filter-repo --path database_dump.sql --invert-paths  # If available
git reflog expire --expire=now --all            # Expire reflog
git gc --prune=now --aggressive                 # Garbage collect
du -sh .git                                     # Check size
```

## Success Criteria

- `database_dump.sql` does not exist in ANY commit in history
- `git rev-list --objects --all | grep database_dump` returns nothing
- `.git` directory is ~100KB or less (not 50MB)
- All other commits (app.py, config.py, README.md changes) are preserved
- `git log --oneline` still shows meaningful commit history
