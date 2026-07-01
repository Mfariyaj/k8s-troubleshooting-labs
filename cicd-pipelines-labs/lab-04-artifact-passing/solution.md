# Solution: Lab 04 - Artifact Passing Between Jobs

## Problem

The deploy job cannot find artifacts produced by the build job. Downloads fail with
"Artifact not found" or the deploy job runs before build completes.

## Diagnosis

```bash
# Check the workflow
cat .github/workflows/ci.yml

# Look for:
# - Artifact name mismatch between upload and download
# - Missing job dependency (needs:)
# - retention-days set to 0
```

## Root Cause

1. **Artifact name mismatch**: The upload step uses one name but download uses another.
2. **Missing `needs:`**: The deploy job doesn't depend on build, so it may run before
   artifacts are available.
3. **Retention set to 0**: Artifacts expire immediately and cannot be downloaded.

## Fix

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          # Use a consistent, exact name
          name: build-output
          path: dist/
          retention-days: 5  # FIXED: Must be > 0

  deploy:
    runs-on: ubuntu-latest
    # FIXED: Add dependency on build job
    needs: [build]

    steps:
      - name: Download build artifact
        uses: actions/download-artifact@v4
        with:
          # FIXED: Must match the upload name exactly
          # BROKEN: name: build-artifacts
          name: build-output
          path: dist/

      - name: Deploy
        run: |
          ls -la dist/
          ./deploy.sh
```

## Key Fixes

| Issue | Broken | Fixed |
|-------|--------|-------|
| Name mismatch | `build-artifacts` vs `build-output` | Same name: `build-output` |
| Job ordering | No dependency | `needs: [build]` |
| Retention | `retention-days: 0` | `retention-days: 5` |

## Verification

- Build job completes and uploads artifact successfully
- Deploy job waits for build to finish (visible in workflow graph)
- Artifact download succeeds with correct files
- `ls dist/` shows expected build output

## Key Takeaways

- Artifact names must be **exactly** the same in upload and download
- Use `needs:` to establish job dependencies and ordering
- `retention-days: 0` means the artifact is never stored
- Use `actions/upload-artifact@v4` and `actions/download-artifact@v4` (matching versions)
