# Solution: Lab 02 - Secrets Exposed in CI/CD

## Problem

Sensitive credentials (API keys, tokens, passwords) are being leaked in CI/CD logs,
making them visible to anyone with access to build output.

## Diagnosis

```bash
# Check the workflow file for secret handling
cat .github/workflows/ci.yml

# Look for:
# - echo ${{ secrets.* }} — prints secret value to logs
# - Secrets in if conditions — exposed in workflow UI
# - Secrets passed as command arguments (visible in process list)
```

## Root Cause

1. **Echoing secrets**: `run: echo ${{ secrets.API_KEY }}` prints the value to logs.
2. **Secrets in `if` conditions**: `if: secrets.TOKEN == 'abc'` exposes the value
   in the workflow run UI.
3. **Missing masking**: Custom secrets aren't registered for masking.

## Fix

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # FIXED: Never echo secrets
      - name: Configure credentials
        env:
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          # BROKEN: echo "Key is ${{ secrets.API_KEY }}"
          # FIXED: Use environment variable, never echo
          echo "API key configured (masked)"

      # FIXED: Register custom values for masking
      - name: Set up token
        run: |
          echo "::add-mask::$CUSTOM_TOKEN"
          # Now this value will be masked in all subsequent log output
        env:
          CUSTOM_TOKEN: ${{ secrets.CUSTOM_TOKEN }}

      # FIXED: Don't use secrets in if conditions
      - name: Deploy
        # BROKEN: if: ${{ secrets.DEPLOY_TOKEN != '' }}
        # FIXED: Check for secret existence differently
        if: ${{ env.HAS_DEPLOY_TOKEN == 'true' }}
        env:
          HAS_DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN != '' }}
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: ./deploy.sh
```

## Verification

- Push the fixed workflow and check the Actions logs
- Secrets should appear as `***` in all log output
- No plaintext credentials visible in workflow run UI

## Key Takeaways

- Never use `echo` or `print` with secret values
- Use `::add-mask::` to register dynamic secrets for masking
- Pass secrets via `env:` block, not inline in `run:` commands
- Don't compare secret values in `if:` conditions
- Audit CI logs regularly for accidentally exposed credentials
- Rotate any secret that has ever appeared in logs
