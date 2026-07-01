# Solution: Lab 10 - Deployment Gates and Rollback

## Problem

Deployment health checks always pass (wrong URL), rollback triggers incorrectly,
and concurrent deployments to different environments interfere with each other.

## Diagnosis

```bash
# Check the workflow
cat .github/workflows/deploy.yml

# Look for:
# - Health check URL that doesn't match actual health endpoint
# - Rollback condition that fires on wrong status
# - Shared concurrency group across environments
```

## Root Cause

1. **Wrong health check URL**: The post-deploy verification hits `/health` but the
   app uses `/api/health` — always returns 404, misinterpreted as success or failure.
2. **Wrong rollback condition**: Rollback triggers on `failure()` but the health check
   step doesn't fail properly (wrong exit code handling).
3. **Shared concurrency group**: Staging and production share the same concurrency
   group, causing one to cancel the other.

## Fix

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    # FIXED: Separate concurrency groups per environment
    # BROKEN: concurrency: deploy
    concurrency:
      group: deploy-${{ matrix.environment }}
      cancel-in-progress: false

    strategy:
      matrix:
        environment: [staging, production]

    steps:
      - uses: actions/checkout@v4

      - name: Deploy
        run: ./deploy.sh ${{ matrix.environment }}

      # FIXED: Correct health check URL
      - name: Health Check
        id: health
        run: |
          # BROKEN: curl -f http://app.example.com/health
          # FIXED: Use correct endpoint with retries
          for i in $(seq 1 10); do
            if curl -sf http://app.example.com/api/health; then
              echo "healthy=true" >> $GITHUB_OUTPUT
              exit 0
            fi
            sleep 10
          done
          echo "healthy=false" >> $GITHUB_OUTPUT
          exit 1

      # FIXED: Rollback condition checks health step output
      - name: Rollback
        # BROKEN: if: failure()  — too broad, catches any failure
        if: steps.health.outputs.healthy == 'false'
        run: ./rollback.sh ${{ matrix.environment }}
```

## Key Fixes

| Issue | Broken | Fixed |
|-------|--------|-------|
| Health URL | `/health` | `/api/health` |
| Rollback condition | `if: failure()` | `if: steps.health.outputs.healthy == 'false'` |
| Concurrency | `group: deploy` | `group: deploy-${{ matrix.environment }}` |

## Verification

- Health check verifies the correct endpoint
- Failed health check triggers rollback for that specific environment
- Staging and production deployments don't cancel each other

## Key Takeaways

- Always verify the exact health check endpoint path
- Use step outputs for precise conditional logic instead of broad `failure()`
- Separate concurrency groups by environment to prevent interference
- Add retries to health checks to handle startup delays
