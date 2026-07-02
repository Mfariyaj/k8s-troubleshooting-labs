## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a local git repo with the broken state)
2. Navigate: `cd /tmp/git-lab-XX/`
3. Investigate: `git status`, `git log --oneline`, `git reflog`
4. Fix the issue using git commands
5. Verify your fix resolves the problem
6. Check `solution.md` if stuck. Cleanup: `./cleanup.sh`

---

# Lab 01: Merge Conflict Resolution

## Difficulty: 🟢 Beginner

## Scenario

Your team has been working on three parallel feature branches (`feature-a`, `feature-b`, `feature-c`). All three branches modify the same files — `config.yaml`, `app.py`, and `README.md` — with conflicting values for ports, versions, connection pools, and application names.

You're the tech lead and need to merge all three branches into `main`, making coherent choices about which values to keep.

## What You'll See

```bash
$ git log --oneline --graph --all
* abc1234 (feature-c) feature-c: production-ready configuration
| * def5678 (feature-b) feature-b: v1.5 with debug logging and new port
|/
| * ghi9012 (feature-a) feature-a: upgrade to v2.0 with new settings
|/
* 345abcd (HEAD -> main) Initial commit: base application setup
```

```bash
$ git merge feature-a
# Succeeds (first merge, no conflicts with main)

$ git merge feature-b
# CONFLICT in config.yaml, app.py, README.md
```

## Hints

1. **Hint 1**: Start by merging feature-a (it merges cleanly into main). Then merge feature-b — this is where conflicts start. Finally merge feature-c.

2. **Hint 2**: Use `git diff --name-only feature-a..feature-b` to see which files conflict. Use `git merge --no-commit` to stage the merge without committing, giving you time to review.

3. **Hint 3**: For each conflicted file, look for `<<<<<<<`, `=======`, `>>>>>>>` markers. You can use `git checkout --theirs <file>` or `git checkout --ours <file>` for whole-file resolution, or manually edit for mixed resolution.

## Useful Commands

```bash
git merge <branch>                  # Attempt merge
git status                          # See conflicted files
git diff                            # See conflict details
git checkout --ours <file>          # Keep current branch version
git checkout --theirs <file>        # Keep incoming branch version
git merge --abort                   # Cancel the merge
git add <file>                      # Mark conflict resolved
git commit                          # Complete the merge
git log --oneline --graph --all     # Visualize branches
git diff <branch1>..<branch2>       # Compare branches
```

## Success Criteria

- All three branches are merged into main
- No conflict markers remain in any file
- `config.yaml`, `app.py`, and `README.md` have coherent, non-contradictory content
- `git log --oneline --graph --all` shows merge commits
