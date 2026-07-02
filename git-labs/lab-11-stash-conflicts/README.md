# Lab 11: Stash Conflicts

## Difficulty: 🟡 Intermediate

## Scenario

A developer was halfway through adding SSL support to the server module. They stashed their work to handle an urgent production hotfix. The hotfix modified the same files (`config.yaml` and `server.py`).

Now when trying to `git stash pop` to resume SSL work, there are merge conflicts. The stash was NOT dropped (because of the conflict), so it still shows in `git stash list`.

## What You'll See

```bash
$ cd /tmp/git-lab-11
$ git status
On branch main
Unmerged paths:
  both modified:   config.yaml
  both modified:   server.py

$ git stash list
stash@{0}: On main: WIP: SSL support in progress

$ cat server.py
# Shows conflict markers between hotfix and SSL changes
```

## Hints

1. **Hint 1**: When `stash pop` conflicts, the stash is NOT dropped. This means you can `git checkout -- .` to reset to clean state and try alternative approaches (like `git stash branch`).

2. **Hint 2**: Resolve conflicts normally: edit the files to combine both SSL support AND the production hotfix, then `git add` the resolved files. After resolution, manually drop the stash with `git stash drop`.

3. **Hint 3**: Alternative approach: `git stash branch ssl-feature` creates a new branch from where the stash was originally created, then applies the stash cleanly there. You can then merge that branch.

## Useful Commands

```bash
git stash list                      # Show all stashes
git stash show -p stash@{0}        # Show stash diff (what was stashed)
git stash pop                       # Apply + drop (fails on conflict)
git stash apply                     # Apply without dropping
git stash drop                      # Manually drop after resolving conflict
git stash branch <name>             # Create branch from stash origin point
git checkout -- .                   # Reset working tree to HEAD
git diff                            # View conflicts
git add <file>                      # Mark resolved
```

## Success Criteria

- No conflict markers in any file
- `server.py` has BOTH SSL support and the health_check endpoint
- `config.yaml` has production settings with additional SSL config
- `git stash list` is empty (stash was dropped after resolution)
- Working tree is clean
