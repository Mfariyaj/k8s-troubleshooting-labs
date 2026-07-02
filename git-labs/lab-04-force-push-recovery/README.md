# Lab 04: Force Push Recovery

## Difficulty: 🟡 Intermediate

## Scenario

Someone on your team force-pushed to `main` after an accidental `git reset --hard HEAD~5`. The remote repository now only has commits 1-5, but there were originally 10 commits with important features (6 through 10).

The remote (simulated as a bare repo) has lost the commits. Your local repo was the one that did the force push, so the reflog still has the original history.

## What You'll See

```bash
$ cd /tmp/git-lab-04/repo
$ git log --oneline
# Only 5 commits visible

$ ls feature-*.py
# Only feature-1.py through feature-5.py

$ git log --oneline origin/main
# Remote also only shows 5 commits
```

## Hints

1. **Hint 1**: The reflog records every position HEAD has been in. Even after `reset --hard`, the old commits exist in the object store. Run `git reflog` to find them.

2. **Hint 2**: Look for the reflog entry that says something like `reset: moving from <sha> to HEAD~5`. The SHA it moved FROM is your full history.

3. **Hint 3**: Once you have the SHA, `git reset --hard <sha>` restores your local, then `git push --force origin main` fixes the remote. Alternatively, `git push origin <sha>:main` pushes without changing local.

## Useful Commands

```bash
git reflog                          # All HEAD movements
git reflog show main                # Main branch reflog
git log --oneline <sha>             # View log from specific commit
git reset --hard <sha>              # Move HEAD to commit
git push --force origin main        # Force push (careful!)
git push origin <sha>:refs/heads/main  # Push specific SHA to remote
git show <sha>                      # Inspect a commit
git rev-parse HEAD@{1}              # Parse reflog references
```

## Success Criteria

- All 10 commits are restored on `main` branch
- `git log --oneline` shows all 10 commits
- Files `feature-1.py` through `feature-10.py` all exist
- Remote (`origin/main`) also has all 10 commits
- `app.py` contains all 10 feature functions
