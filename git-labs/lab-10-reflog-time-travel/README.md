# Lab 10: Reflog Time Travel

## Difficulty: 🟡 Intermediate

## Scenario

A developer accidentally ran `git reset --hard HEAD~5` while on `main`. This moved the branch pointer back 5 commits AND wiped the working directory. Files `module_6.py` through `module_10.py` are gone from both the working tree and git log.

## What You'll See

```bash
$ cd /tmp/git-lab-10
$ git log --oneline
abc1234 feat: add module 5 (critical business logic)
def5678 feat: add module 4 (critical business logic)
ghi9012 feat: add module 3 (critical business logic)
jkl3456 feat: add module 2 (critical business logic)
mno7890 feat: add module 1 (critical business logic)

$ ls module_*.py
module_1.py  module_2.py  module_3.py  module_4.py  module_5.py
# Modules 6-10 MISSING!
```

## Hints

1. **Hint 1**: `git reflog` shows every position HEAD has been at. The entry just BEFORE the reset (`HEAD@{1}`) is where all 10 commits were.

2. **Hint 2**: `git reset --hard HEAD@{1}` will undo the accidental reset, restoring the branch pointer AND working tree to the pre-reset state.

3. **Hint 3**: Alternative: `git reflog` shows the SHA of the pre-reset commit. Use `git reset --hard <sha>` with that specific SHA. Or `git branch recovery <sha>` to keep both states.

## Useful Commands

```bash
git reflog                          # Show all HEAD movements
git reflog show main                # Main branch reflog specifically
git reset --hard HEAD@{1}           # Undo the last reset
git reset --hard <sha>              # Reset to specific commit
git branch recovery <sha>           # Create branch at SHA (non-destructive)
git show HEAD@{1}                   # Preview what was at that position
git diff HEAD HEAD@{1}              # See what was lost
```

## Success Criteria

- All 10 commits are visible in `git log --oneline`
- Files `module_1.py` through `module_10.py` all exist
- Working tree is clean (`git status` shows nothing to commit)
- Each module file contains its correct business logic
