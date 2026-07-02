# Lab 05: Submodule Sync Broken

## Difficulty: 🟡 Intermediate

## Scenario

Your project uses a Git submodule (`libs/shared`) to include a shared library. After a teammate modified paths and multiple people tried to fix things, the submodule is completely broken:

1. `.gitmodules` has a wrong URL path
2. `.git/config` has a DIFFERENT wrong URL (doesn't match .gitmodules)
3. The submodule is checked out at the wrong commit (v3 instead of v2)
4. The submodule is in detached HEAD state

## What You'll See

```bash
$ cd /tmp/git-lab-05/project
$ git submodule status
+abc1234 libs/shared (heads/main)     # '+' means commit mismatch

$ cat .gitmodules
[submodule "libs/shared"]
    path = libs/shared
    url = /tmp/git-lab-05/WRONG-PATH/shared-lib.git   # WRONG!

$ git config --get submodule.libs/shared.url
/tmp/git-lab-05/ANOTHER-WRONG-PATH                     # ALSO WRONG!

$ git submodule update
fatal: repository '/tmp/git-lab-05/ANOTHER-WRONG-PATH' does not exist
```

## Hints

1. **Hint 1**: The correct path to the library repo is `/tmp/git-lab-05/shared-lib.git`. You need to fix BOTH `.gitmodules` AND `.git/config`.

2. **Hint 2**: After fixing URLs, run `git submodule sync` to propagate `.gitmodules` URL into `.git/config`. Then `git submodule update` to reset to the correct commit.

3. **Hint 3**: The parent repo's index records which commit SHA the submodule should be at. Use `git diff --cached libs/shared` or `git ls-tree HEAD libs/shared` to see what the parent expects.

## Useful Commands

```bash
git submodule status                # Show submodule state (+ means mismatch)
git submodule sync                  # Sync URLs from .gitmodules to .git/config
git submodule update --init         # Initialize and checkout correct commit
cat .gitmodules                     # View submodule definitions
git config --get submodule.libs/shared.url  # Check actual URL in config
git ls-tree HEAD libs/shared        # See expected commit SHA
git -C libs/shared log --oneline    # Log inside submodule
git diff --submodule                # Submodule diff
```

## Success Criteria

- `git submodule status` shows no `+` prefix (commit matches)
- `.gitmodules` URL is correct and accessible
- `git submodule sync && git submodule update` works without errors
- `libs/shared/lib.py` contains `v2` (not v3)
- No detached HEAD warning in submodule
