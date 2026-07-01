# Solution: Lab 05 - Environment Protection Rules

## Problem

Deployments to production proceed without required approvals, or deployments are
blocked indefinitely because protection rules are misconfigured.

## Diagnosis

```bash
# Check workflow configuration
cat .github/workflows/deploy.yml

# Look for:
# - environment: production without reviewers configured
# - Branch protection rules not matching workflow branch
# - Missing environment configuration in repo settings
```

## Root Cause

1. **No reviewers configured**: The GitHub environment "production" exists but has no
   required reviewers set, so deployments auto-approve.
2. **Branch protection mismatch**: Protection rules target `main` but workflow runs
   from a different branch or uses wrong ref.

## Fix

### Step 1: Configure environment reviewers (GitHub UI)

```
Repository Settings → Environments → production:
  ✅ Required reviewers: Add team leads / SREs
  ✅ Wait timer: 5 minutes (optional)
  ✅ Deployment branches: Selected branches → main
```

### Step 2: Fix workflow to use environments correctly

```yaml
jobs:
  deploy-production:
    runs-on: ubuntu-latest
    # This triggers the environment protection rules
    environment:
      name: production
      url: https://myapp.example.com
    needs: [test, build]

    # Only deploy from main branch
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: ./deploy.sh production
```

### Step 3: Configure branch protection

```
Repository Settings → Branches → main:
  ✅ Require pull request reviews before merging
  ✅ Require status checks to pass: [test, build]
  ✅ Restrict who can push to matching branches
```

## Verification

- Push to main → workflow triggers → pauses at deploy job waiting for approval
- Reviewer approves → deployment proceeds
- Push to non-main branch → deploy job is skipped (`if:` condition)
- Direct push to main is blocked by branch protection

## Key Takeaways

- `environment:` in a job enables GitHub's deployment protection rules
- Reviewers must be configured in repo Settings → Environments (not in YAML)
- Use `if: github.ref == 'refs/heads/main'` to restrict deployment branches
- Branch protection and environment protection are complementary
