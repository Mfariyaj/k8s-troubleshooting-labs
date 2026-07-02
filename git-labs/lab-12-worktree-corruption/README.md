## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a local git repo with the broken state)
2. Navigate: `cd /tmp/git-lab-XX/`
3. Investigate: `git status`, `git log --oneline`, `git reflog`
4. Fix the issue using git commands
5. Verify your fix resolves the problem
6. Check `solution.md` if stuck. Cleanup: `./cleanup.sh`

---

# Lab 12: Worktree Corruption

## Difficulty: 🔴 Advanced

## Scenario

A developer set up 3 git worktrees for parallel feature development, but through accidents and misguided cleanup:

1. **auth worktree**: Directory was deleted with `rm -rf` (without `git worktree remove`)
2. **api worktree**: Branch was force-deleted while worktree existed, metadata corrupted
3. **dashboard worktree**: Directory deleted, metadata remains

Now `git worktree list` shows broken entries, and git operations may fail with stale lock errors.

## What You'll See

```bash
$ cd /tmp/git-lab-12
$ git worktree list
/tmp/git-lab-12                       abc1234 [main]
/tmp/git-lab-12-worktree-auth         def5678 [feature-auth]     (BROKEN)
/tmp/git-lab-12-worktree-api          ghi9012 [feature-api]      (BROKEN)
/tmp/git-lab-12-worktree-dashboard    jkl3456 [feature-dashboard] (BROKEN)

$ ls /tmp/git-lab-12-worktree-*
ls: cannot access '/tmp/git-lab-12-worktree-*': No such file or directory

$ ls .git/worktrees/
git-lab-12-worktree-api  git-lab-12-worktree-auth  git-lab-12-worktree-dashboard
```

## Hints

1. **Hint 1**: `git worktree prune` removes worktree entries whose directories no longer exist. This handles the auth and dashboard worktrees. But you may want to recover work first.

2. **Hint 2**: Before pruning, check if important commits exist on those branches using `git log feature-auth` (if the branch still exists). Use reflog if branches were deleted.

3. **Hint 3**: For the api worktree, the branch ref was deleted. Check `git reflog` or `.git/worktrees/git-lab-12-worktree-api/HEAD` to find the commit SHA and recreate the branch.

## Useful Commands

```bash
git worktree list                   # List all worktrees
git worktree prune                  # Remove stale worktree entries
git worktree remove <path>          # Properly remove a worktree
git worktree repair                 # Repair worktree links (Git 2.30+)
ls .git/worktrees/                  # Raw worktree metadata
cat .git/worktrees/<name>/HEAD      # Where worktree's HEAD points
cat .git/worktrees/<name>/gitdir    # Link to worktree directory
git branch -a                       # Check surviving branches
git reflog                          # Find lost commits
```

## Success Criteria

- `git worktree list` shows only valid, existing worktrees
- No stale entries in `.git/worktrees/`
- Commits from all three feature branches are preserved (on branches or known SHAs)
- The api branch work (api.py commit) is recoverable
- `git status` works cleanly
