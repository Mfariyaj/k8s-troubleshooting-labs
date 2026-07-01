# Solution: Lab 01 - GitHub Actions Syntax Errors

## Problem

GitHub Actions workflow fails to run with parsing errors. The workflow never starts
or shows "Invalid workflow file" in the Actions tab.

## Diagnosis

```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"

# Check for common issues
cat .github/workflows/ci.yml

# Look for:
# - Indentation errors
# - Missing action version tags
# - Invalid trigger syntax
```

## Root Cause

Three syntax issues in the workflow file:

1. **YAML indentation errors**: Steps or jobs are not properly indented (must use
   consistent 2-space indentation).
2. **Missing `@version` on `uses`**: Actions must specify a version tag
   (e.g., `uses: actions/checkout@v4` not `uses: actions/checkout`).
3. **Invalid trigger syntax**: The `on:` section has incorrect event configuration.

## Fix

```yaml
# .github/workflows/ci.yml

# FIXED: Correct trigger syntax
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    # FIXED: Proper indentation for steps
    steps:
      # FIXED: Add @version to uses
      - uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test
```

## Key Fixes Summary

| Issue | Broken | Fixed |
|-------|--------|-------|
| Indentation | 3 spaces or tabs | 2-space consistent |
| Action version | `actions/checkout` | `actions/checkout@v4` |
| Trigger | `on: push, pull_request` | `on:\n  push:\n  pull_request:` |

## Verification

```bash
# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"

# Use actionlint for deeper validation
actionlint .github/workflows/ci.yml

# Push and check Actions tab
git add . && git commit -m "fix: workflow syntax" && git push
```

## Key Takeaways

- Always pin action versions with `@v4` or commit SHA for security
- YAML is indentation-sensitive — use 2 spaces, never tabs
- `on:` trigger must use proper mapping syntax for event configuration
- Use `actionlint` locally to catch errors before pushing
