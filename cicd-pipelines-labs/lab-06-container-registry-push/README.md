# Lab 06: Container Registry Push Failures

## 🎯 Scenario

The team set up a workflow to build Docker images and push them to both GitHub Container Registry (ghcr.io) and Docker Hub. However, the pushes are failing due to authentication issues, wrong registry URLs, and invalid image tag formats. The GITHUB_TOKEN also lacks the necessary permissions.

## 🔴 Difficulty: Hard

## 📋 Error Output

GitHub Actions shows:

```
Run docker/login-action@v3 (Login to GitHub Container Registry)
  Logging into gcr.io...
  Error: Error response from daemon: login attempt to https://gcr.io/v2/ failed
  with status: 403 Forbidden
  
  Note: GitHub Container Registry is 'ghcr.io', not 'gcr.io' (Google Container Registry)

Run docker push ghcr.io/myorg/my-app:refs/heads/main
  Error: invalid reference format: repository name must be lowercase
  Error: 'refs/heads/main' contains invalid characters for a tag.
  Tags cannot contain '/'. Did you mean to use github.ref_name instead of github.ref?

Run docker push ghcr.io/myorg/my-app:latest
  Error: denied: permission_denied: write_package
  The GITHUB_TOKEN does not have 'packages: write' permission.
  Add 'permissions: packages: write' to the workflow or job.

Run docker push myuser/my-app:v1.0.0
  Error: denied: requested access to the resource is denied
  Ensure Docker Hub credentials are correct and the repository exists.
```

## 🐛 Debugging Steps

1. Check registry URL:
   ```
   gcr.io → Google Container Registry (WRONG)
   ghcr.io → GitHub Container Registry (CORRECT)
   ```

2. Check image tag format:
   ```
   ${{ github.ref }} = "refs/heads/main" → Contains '/' — invalid tag!
   ${{ github.ref_name }} = "main" → Valid tag
   ```

3. Check GITHUB_TOKEN permissions:
   ```yaml
   # Missing from workflow:
   permissions:
     contents: read
     packages: write
   ```

4. Verify Docker Hub login is using correct credentials

## 💡 Hints

<details>
<summary>Hint 1</summary>
The GHCR login uses `gcr.io` (Google Container Registry) instead of `ghcr.io` (GitHub Container Registry). One letter makes all the difference!
</details>

<details>
<summary>Hint 2</summary>
`${{ github.ref }}` outputs `refs/heads/main` which contains `/` characters. Docker tags cannot contain `/`. Use `${{ github.ref_name }}` which outputs just `main` or the tag name.
</details>

<details>
<summary>Hint 3</summary>
The workflow is missing `permissions: packages: write`. Without this, the GITHUB_TOKEN cannot push to ghcr.io. Add a permissions block at the workflow or job level.
</details>

## 🔧 Issues to Fix

1. Registry URL `gcr.io` should be `ghcr.io` for GitHub Container Registry
2. `${{ github.ref }}` produces `refs/heads/main` — invalid Docker tag (use `github.ref_name`)
3. Missing `permissions: packages: write` for GITHUB_TOKEN to push to GHCR
4. No `permissions: contents: read` (needed when you set any permissions block)
5. Docker Hub push may fail if repository doesn't exist or credentials are wrong
