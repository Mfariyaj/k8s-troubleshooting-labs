## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a local git repo with the broken state)
2. Navigate: `cd /tmp/git-lab-XX/`
3. Investigate: `git status`, `git log --oneline`, `git reflog`
4. Fix the issue using git commands
5. Verify your fix resolves the problem
6. Check `solution.md` if stuck. Cleanup: `./cleanup.sh`

---

# Lab 02: Detached HEAD Recovery

## Difficulty: 🟢 Beginner

## Scenario

A developer was investigating a production bug and checked out an old commit to test something. While in the detached HEAD state, they made two important commits:
1. An emergency hotfix for production
2. Added monitoring to the hotfix

They then switched back to `main` — and now the commits are gone! They don't appear in `git log --all` or on any branch.

## What You'll See

```bash
$ cd /tmp/git-lab-02
$ git log --oneline --all
# Only shows the 5 main branch commits — hotfix commits are MISSING

$ git branch -a
# Only shows 'main'

$ git status
# On branch main, clean working tree
```

## Hints

1. **Hint 1**: Commits are never truly deleted immediately in git. Even without a branch pointing to them, they exist in the object store. The `reflog` tracks all HEAD movements.

2. **Hint 2**: Run `git reflog` — you'll see entries for the detached HEAD commits. The SHA hashes are still valid.

3. **Hint 3**: Once you find the SHA of the lost commit, create a branch pointing to it with `git branch <name> <sha>`.

## Useful Commands

```bash
git reflog                          # All HEAD movements including detached
git reflog show HEAD                # Detailed HEAD reflog
git log --oneline --all             # All branches (won't show orphaned commits)
git branch <name> <sha>             # Create branch at specific commit
git cherry-pick <sha>               # Apply a commit to current branch
git show <sha>                      # Inspect a specific commit
git fsck --lost-found               # Find unreachable objects
```

## Success Criteria

- Both lost commits are recovered
- They exist on a proper branch (e.g., `hotfix-recovery`)
- The commit messages "IMPORTANT: emergency hotfix" and "IMPORTANT: added monitoring" are preserved
- `git log hotfix-recovery` shows both commits
