# Lab 03: Rebase Gone Wrong

## Difficulty: 🟡 Intermediate

## Scenario

A developer started an interactive rebase of their feature branch (3 commits) onto the latest `main`. The rebase hit conflicts on the very first commit and is now stuck in a mid-rebase state.

The working directory has conflict markers in `app.py`, and `git status` shows "rebase in progress."

## What You'll See

```bash
$ cd /tmp/git-lab-03
$ git status
interactive rebase in progress; onto abc1234
Last command done (1 command done):
   pick def5678 Feature: added setup_logging
Next commands to do (2 remaining commands):
   pick ghi9012 Feature: added validate_env
   pick jkl3456 Feature: added init_cache

You are currently rebasing branch 'feature' on 'abc1234'.
  (fix conflicts and then run "git rebase --continue")
  (use "git rebase --skip" to skip this patch)
  (use "git rebase --abort" to check out the original branch)

Unmerged paths:
  both modified:   app.py
```

## Hints

1. **Hint 1**: You have three options: `--abort` (go back to before the rebase), `--skip` (skip the conflicting commit), or resolve and `--continue`. Consider: which approach preserves all your work?

2. **Hint 2**: To resolve the conflict, you need to combine BOTH versions — the main branch's `load_config/connect_db/start_server` functions AND the feature branch's `setup_logging` function. Open `app.py` and merge both sets of code.

3. **Hint 3**: After resolving this first commit's conflict and running `git rebase --continue`, you'll likely hit conflicts on commits 2 and 3 as well. Each one needs individual resolution. Consider if `git rebase --abort` + `git merge main` might be simpler.

## Useful Commands

```bash
git status                          # Shows rebase state
git rebase --abort                  # Cancel entire rebase
git rebase --continue               # Continue after resolving
git rebase --skip                   # Skip current commit
git diff                            # Show conflicts
cat .git/rebase-merge/done          # See completed rebase steps
cat .git/rebase-merge/git-rebase-todo  # See remaining steps
git reflog                          # Find pre-rebase state (ORIG_HEAD)
git reset --hard ORIG_HEAD          # Alternative abort method
```

## Success Criteria

- Repository is no longer in mid-rebase state
- Feature branch has all its functionality (setup_logging, validate_env, init_cache)
- Main branch's functionality is preserved (load_config, connect_db, start_server)
- Clean `git status` — no unresolved conflicts
