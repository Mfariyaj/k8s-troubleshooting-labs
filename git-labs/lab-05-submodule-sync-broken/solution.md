# Lab 05: Solution — Submodule Sync Broken

## Root Cause

Multiple issues compound:
1. `.gitmodules` URL was changed to a non-existent path
2. `.git/config` has a different non-existent path (because sync wasn't run)
3. The submodule working tree is at v3 but the parent repo index expects v2

## Fix Commands

```bash
cd /tmp/git-lab-05/project

# Step 1: Fix .gitmodules URL
sed -i 's|/tmp/git-lab-05/WRONG-PATH/shared-lib.git|/tmp/git-lab-05/shared-lib.git|' .gitmodules

# Step 2: Sync .gitmodules URL to .git/config
git submodule sync

# Verify
git config --get submodule.libs/shared.url
# Should now show: /tmp/git-lab-05/shared-lib.git

# Step 3: Update submodule to the commit recorded in parent's index
git submodule update --init

# Step 4: Verify the submodule is at v2
cat libs/shared/lib.py
# Should show: def helper(): return "v2"

# Step 5: Commit the .gitmodules fix
git add .gitmodules
git commit -m "Fix submodule URL path"

# Step 6: Final verification
git submodule status
# Should show clean status (no + prefix, correct SHA)
```

## Git Internals Explained

### How Submodules Work

1. **`.gitmodules`**: Tracked file that defines submodule name, path, and URL. Shared with all collaborators.

2. **`.git/config`**: Local config that stores the actual URL used for fetch/push. NOT shared — each clone generates its own from `.gitmodules` during `git submodule init`.

3. **Tree entry**: The parent repo stores a special "gitlink" entry in its tree object — a commit SHA that the submodule should be checked out at. This is visible with `git ls-tree HEAD libs/shared`.

4. **`.git/modules/<name>/`**: Actual git database for the submodule (since Git 1.7.8, submodule .git dirs are stored here, with the submodule directory containing a `.git` file pointing to it).

### Common Submodule Issues

| Problem | Symptom | Fix |
|---------|---------|-----|
| URL mismatch | `git submodule update` fails | Fix `.gitmodules` + `git submodule sync` |
| Wrong commit | `+` in `git submodule status` | `git submodule update` |
| Not initialized | `-` in `git submodule status` | `git submodule init` |
| Detached HEAD | Can't `git pull` in submodule | `cd submodule && git checkout main` |

### The Sync Flow

```
.gitmodules (source of truth, tracked)
    |
    v  [git submodule sync]
.git/config (local copy, used for operations)
    |
    v  [git submodule update]
libs/shared/ (working tree checkout at recorded commit)
```

### Prevention

- Always run `git submodule sync` after changing `.gitmodules`
- Use `git submodule update --init --recursive` after cloning
- Consider `git clone --recurse-submodules` for initial clone
- Pin submodules to specific tags rather than floating branches
