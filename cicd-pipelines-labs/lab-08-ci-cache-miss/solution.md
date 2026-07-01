# Solution: Lab 08 - CI Cache Miss

## Problem

CI pipeline never hits the cache — every run downloads and installs all dependencies
from scratch, making builds unnecessarily slow.

## Diagnosis

```bash
# Check workflow cache configuration
cat .github/workflows/ci.yml

# Look for:
# - hashFiles path doesn't match actual lock file location
# - Using npm ci after cache restore (which deletes node_modules)
# - restore-keys too specific (no fallback)

# In GitHub Actions, check the "Post cache" step output
# "Cache not found for input keys: ..."
```

## Root Cause

1. **Wrong `hashFiles` path**: The path to `package-lock.json` doesn't match the
   actual file location in the repo (e.g., missing subdirectory).
2. **Running `npm ci` after cache restore**: `npm ci` deletes `node_modules` entirely
   before reinstalling — negating the cache benefit.
3. **`restore-keys` too specific**: No fallback key means partial cache hits never occur.

## Fix

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache node_modules
        uses: actions/cache@v4
        id: cache-deps
        with:
          path: node_modules
          # FIXED: Correct path to lock file
          # BROKEN: key: deps-${{ hashFiles('package-lock.json') }}
          key: deps-${{ hashFiles('**/package-lock.json') }}
          # FIXED: Add broader restore-keys for partial matches
          restore-keys: |
            deps-

      # FIXED: Only install if cache missed
      # BROKEN: Always running "npm ci" which deletes node_modules
      - name: Install dependencies
        if: steps.cache-deps.outputs.cache-hit != 'true'
        run: npm install

      - name: Run tests
        run: npm test
```

## Key Fixes

| Issue | Broken | Fixed |
|-------|--------|-------|
| hashFiles path | `hashFiles('package-lock.json')` | `hashFiles('**/package-lock.json')` |
| Install command | Always `npm ci` | Conditional `npm install` (skip on cache hit) |
| restore-keys | Not specified | `deps-` (broad fallback) |

## Verification

- First run: Cache miss → installs deps → saves cache
- Second run: Cache hit → skips install → uses cached node_modules
- Check "Cache" step output shows "Cache restored from key: deps-..."
- Build time significantly reduced on cache hits

## Key Takeaways

- `hashFiles` uses glob patterns relative to repo root — use `**/` for subdirectories
- `npm ci` always deletes `node_modules` — don't use it with caching
- `restore-keys` provides fallback when exact key doesn't match
- Use `if: steps.<id>.outputs.cache-hit != 'true'` to skip install on hit
