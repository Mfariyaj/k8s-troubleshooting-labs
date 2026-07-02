## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a git repo with broken workflow)
2. Review the broken workflow YAML (.github/workflows/ or .gitlab-ci.yml)
3. Identify the syntax errors, logic issues, or misconfiguration
4. Fix the workflow file
5. Validate with: `actionlint` (GitHub Actions) or CI Lint API (GitLab)
6. Check `solution.md` if stuck

---

# Lab 08: CI Cache Misses

## 🎯 Scenario

The CI pipeline is slow because caching isn't working properly. Dependencies are being re-downloaded on every run despite cache configuration being present. The cache keys are misconfigured — using wrong file paths for hashing, overly specific restore keys, and `npm ci` is wiping the cached `node_modules` directory.

## 🔴 Difficulty: Medium

## 📋 Error Output

### GitHub Actions:

```
Run actions/cache@v4
  Cache key: Linux-node-e3b0c44298fc1c149afbf4c8996fb924
  (hashFiles('**/yarn.lock') returned empty hash — file does not exist!)
  
  Restore keys:
    Linux-node-a1b2c3d4e5f6-exact-v2
    Linux-node-a1b2c3d4e5f6-exact-v1
  
  Cache not found for keys:
    Linux-node-e3b0c44298fc1c149afbf4c8996fb924
    Linux-node-a1b2c3d4e5f6-exact-v2
    Linux-node-a1b2c3d4e5f6-exact-v1
  
  (restore-keys are too specific — they include hashFiles and version suffixes,
   defeating the purpose of prefix-based fallback matching)

Run npm ci
  npm warn: npm ci removes existing node_modules before install
  (Cache restored node_modules/ but npm ci deleted it and reinstalled from scratch!)

Build cache:
  Cache key: Linux-nextjs-abc123hash
  Restore keys contain hashFiles — these should be simple prefixes for fallback
```

### GitLab CI:

```
Restoring cache...
  Checking cache for yarn.lock-based key...
  WARNING: cache key uses 'yarn.lock' but project uses 'package-lock.json'
  No cache found.

test job:
  Cache key: test-specific-runner-12345-a1b2c3d-package.json-hash
  Key is too specific (includes runner ID and commit SHA) — will never match previous runs!
  
  Running 'npm ci'...
  npm warn: Removing existing node_modules/
  (npm ci always deletes node_modules — caching node_modules with npm ci is pointless!)

lint job:
  Cache key: static-key-that-never-changes
  Cache policy: pull (never writes back to cache)
  Cache will always contain stale dependencies if never updated!
```

## 🐛 Debugging Steps

1. Check which lock file the project uses:
   ```
   hashFiles('**/yarn.lock') → Returns empty if project uses package-lock.json!
   ```

2. Understand `npm ci` behavior:
   ```
   npm ci ALWAYS deletes node_modules before installing
   → Caching node_modules is useless with npm ci
   → Cache ~/.npm (npm cache directory) instead, OR use 'npm install'
   ```

3. Review restore-keys pattern:
   ```
   Restore keys should be SHORT PREFIXES for fallback:
   ✗ ${{ runner.os }}-node-${{ hashFiles('...') }}-exact-v2
   ✓ ${{ runner.os }}-node-
   ```

4. GitLab: Check cache key specificity (runner ID + commit SHA = unique every run)

## 💡 Hints

<details>
<summary>Hint 1</summary>
The GitHub Actions cache uses `hashFiles('**/yarn.lock')` but the project uses npm (package-lock.json). The hash returns empty/default because yarn.lock doesn't exist.
</details>

<details>
<summary>Hint 2</summary>
`npm ci` ALWAYS removes `node_modules/` before installing. Caching `node_modules/` path is useless with `npm ci`. Either cache `~/.npm` (the npm cache directory) or switch to `npm install`.
</details>

<details>
<summary>Hint 3</summary>
`restore-keys` should be SHORT prefixes that provide fallback matches (e.g., `Linux-node-`). Including hashFiles in restore-keys defeats their purpose because they'll only match exact same dependencies.
</details>

## 🔧 Issues to Fix

### GitHub Actions:
1. `hashFiles('**/yarn.lock')` — project uses npm, should be `**/package-lock.json`
2. Caching `node_modules` path but using `npm ci` (which deletes node_modules)
3. `restore-keys` contain `hashFiles()` and version suffixes — should be simple prefixes
4. Build cache restore-keys also too specific

### GitLab CI:
1. Cache key files references `yarn.lock` — should be `package-lock.json`
2. Test job cache key includes `CI_RUNNER_ID` and `CI_COMMIT_SHORT_SHA` — unique every run
3. `npm ci` in test job deletes cached `node_modules/`
4. Lint job has `policy: pull` only — cache is never updated
