# Lab 14: Sparse Checkout Broken

## Difficulty: 🔴 Advanced

## Scenario

You're working in a large monorepo with this structure:
```
services/auth/, services/api/, services/dashboard/
libs/common/, libs/utils/, libs/crypto/
infrastructure/terraform/, infrastructure/ansible/
docs/api/, docs/internal/
tools/scripts/, tools/ci/
```

You only need `services/api/` and `libs/common/` for your work. Sparse checkout was configured, but now it's broken due to corrupted configuration:
1. The `.git/info/sparse-checkout` file has mixed cone and non-cone mode patterns
2. `core.sparseCheckoutCone` was toggled off but patterns still assume cone mode
3. Conflicting negation patterns

## What You'll See

```bash
$ cd /tmp/git-lab-14/workspace
$ ls
# Shows unexpected files — either too many or wrong directories

$ cat .git/info/sparse-checkout
/*
!/*/
/services/api/
/libs/common/
/services/auth
!/services/auth/**
**/*.yaml
!**/node_modules/**

$ git sparse-checkout list
# May show errors or unexpected patterns
```

## Hints

1. **Hint 1**: The cleanest fix is to disable and re-enable sparse checkout from scratch. Use `git sparse-checkout disable` to restore all files, then `git sparse-checkout init --cone` and `git sparse-checkout set services/api libs/common`.

2. **Hint 2**: If `disable` doesn't work due to corruption, manually fix `.git/info/sparse-checkout` and config: `git config core.sparseCheckoutCone true`, then write proper cone-mode entries.

3. **Hint 3**: In cone mode, the file format is simple: one directory per line with trailing `/`. The `/*` and `!/*/` are auto-generated prefixes. Don't mix glob patterns (`**/*.yaml`) with cone mode.

## Useful Commands

```bash
git sparse-checkout list            # Current sparse patterns
git sparse-checkout set <dirs>      # Set directories (cone mode)
git sparse-checkout disable         # Turn off sparse (show all files)
git sparse-checkout init --cone     # Re-initialize cone mode
git sparse-checkout init --no-cone  # Re-initialize pattern mode
cat .git/info/sparse-checkout       # Raw pattern file
git config core.sparseCheckout      # Is sparse enabled?
git config core.sparseCheckoutCone  # Is cone mode enabled?
git read-tree -mu HEAD              # Re-apply sparse patterns
```

## Success Criteria

- Only `services/api/`, `libs/common/`, and top-level files (README.md) are checked out
- `services/auth/`, `services/dashboard/`, `infrastructure/`, etc. are NOT in working tree
- `git sparse-checkout list` shows correct, clean patterns
- `git status` is clean (no untracked files from sparse switching)
- Running `ls services/` shows only `api/`
