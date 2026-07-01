# Solution: Lab 09 - Conditional Execution Issues

## Problem

Jobs run when they shouldn't (e.g., deploy on feature branches), or required jobs
are skipped (e.g., tests not running on code changes).

## Diagnosis

```bash
# Check workflow conditions
cat .github/workflows/ci.yml
cat .gitlab-ci.yml

# Look for:
# - paths filter not matching actual file paths
# - Wrong context in if conditions (github.event vs github.ref)
# - always() causing jobs to run even when they shouldn't
```

## Root Cause

1. **Paths filter incorrect**: The `paths:` trigger filter doesn't match the actual
   source file locations, so the workflow never triggers on code changes.
2. **Wrong `if` condition context**: Using wrong expression (e.g., `github.event`
   instead of `github.ref` for branch checks).
3. **`always()` misuse**: Using `always()` causes cleanup/notification jobs to run
   even on cancelled workflows, potentially deploying broken code.

## Fix

```yaml
on:
  push:
    branches: [main, develop]
    # FIXED: Correct paths filter to match actual source locations
    # BROKEN: paths: ['source/**']
    paths:
      - 'src/**'
      - 'package.json'
      - 'package-lock.json'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test

  deploy:
    needs: [test]
    runs-on: ubuntu-latest
    # FIXED: Use correct context for branch check
    # BROKEN: if: github.event.ref == 'main'
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - run: ./deploy.sh

  notify:
    needs: [deploy]
    runs-on: ubuntu-latest
    # FIXED: Remove always() — use success()/failure() instead
    # BROKEN: if: always()
    if: success() || failure()
    steps:
      - run: ./notify.sh ${{ job.status }}
```

## Key Fixes

| Issue | Broken | Fixed |
|-------|--------|-------|
| Paths filter | `source/**` | `src/**` (actual directory) |
| If condition | `github.event.ref == 'main'` | `github.ref == 'refs/heads/main'` |
| Always | `if: always()` | `if: success() \|\| failure()` |

## Verification

- Change in `src/` triggers the workflow
- Deploy only runs on `main` branch pushes
- Notify runs on success or failure, but NOT on cancelled workflows

## Key Takeaways

- `paths:` must match actual repository file paths (case-sensitive)
- Use `github.ref` for branch checks, format is `refs/heads/branch-name`
- `always()` includes cancelled — usually not desired; use `success() || failure()`
- Test path filters with `act` or by pushing to a feature branch first
