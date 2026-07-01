# Solution: Lab 06 - Container Registry Push Failure

## Problem

The CI/CD pipeline fails to push Docker images to the container registry with
authentication or permission errors.

## Diagnosis

```bash
# Check the workflow
cat .github/workflows/ci.yml

# Look for:
# - Wrong registry URL (docker.io vs ghcr.io)
# - Missing permissions: packages: write
# - Authentication issues

# Common errors:
# "denied: permission_denied" or "unauthorized: authentication required"
```

## Root Cause

1. **Wrong registry URL**: Workflow pushes to `docker.io` instead of `ghcr.io`
   (GitHub Container Registry).
2. **Missing permissions**: The workflow doesn't have `packages: write` permission
   needed to push to GHCR.

## Fix

```yaml
name: Build and Push

on:
  push:
    branches: [main]

# FIXED: Add required permissions
permissions:
  contents: read
  packages: write

jobs:
  build-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          # BROKEN: registry: docker.io
          # FIXED: Use GitHub Container Registry
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          # FIXED: Use ghcr.io with correct repository path
          tags: ghcr.io/${{ github.repository }}:latest
```

## Key Fixes

| Issue | Broken | Fixed |
|-------|--------|-------|
| Registry URL | `docker.io` | `ghcr.io` |
| Permissions | Not specified | `packages: write` |
| Auth | Wrong credentials | `GITHUB_TOKEN` with correct registry |

## Verification

- Workflow pushes image successfully (green check)
- Image visible at `https://github.com/USER/REPO/pkgs/container/REPO`
- `docker pull ghcr.io/USER/REPO:latest` works

## Key Takeaways

- GHCR requires `permissions: packages: write` in the workflow
- Use `ghcr.io` as the registry URL for GitHub Container Registry
- `GITHUB_TOKEN` works for GHCR auth — no need for personal tokens
- The image tag must include the full `ghcr.io/owner/repo` path
