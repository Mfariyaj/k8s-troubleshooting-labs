## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a git repo with broken workflow)
2. Review the broken workflow YAML (.github/workflows/ or .gitlab-ci.yml)
3. Identify the syntax errors, logic issues, or misconfiguration
4. Fix the workflow file
5. Validate with: `actionlint` (GitHub Actions) or CI Lint API (GitLab)
6. Check `solution.md` if stuck

---

# Lab 03: Matrix Strategy Overload

## 🎯 Scenario

A DevOps engineer set up a comprehensive test matrix to cover all possible combinations of platforms, Node.js versions, databases, and services. The workflow fails to start with errors about exceeding GitHub's matrix job limits. Additionally, the Docker build job is configured to run on Windows, which doesn't support Linux containers natively.

## 🔴 Difficulty: Medium

## 📋 Error Output

GitHub Actions shows:

```
Error: Matrix job 'test' would generate 432 jobs (9 platforms × 6 node-versions × 4 databases × 2 redis-versions).
GitHub Actions has a maximum of 256 jobs per matrix.
Please reduce the number of combinations or use include/exclude.

Error: Matrix job 'integration' would generate 192 jobs (8 services × 6 environments × 4 regions).
GitHub Actions has a maximum of 256 jobs per matrix.

Warning: Job 'docker-build' uses matrix platform 'windows-latest' but runs Docker commands.
Docker Linux containers are not natively supported on Windows runners without additional setup.

Error in 'test' job strategy.matrix.exclude:
  Invalid exclude format. Expected a list of mappings, got a single mapping.
  exclude:
    platform: windows-latest    # ← Should be a list item with `-`
    node-version: 14
```

## 🐛 Debugging Steps

1. Calculate total matrix combinations:
   ```
   test: 9 × 6 × 4 × 2 = 432 combinations (exceeds 256 limit)
   integration: 8 × 6 × 4 = 192 combinations (within limit but excessive)
   ```

2. Check the `exclude` syntax — it should be a list:
   ```yaml
   exclude:
     - platform: windows-latest
       node-version: 14
   ```

3. Verify Docker compatibility on Windows runners

4. Review if all matrix combinations are actually needed

## 💡 Hints

<details>
<summary>Hint 1</summary>
GitHub Actions has a hard limit of 256 jobs per workflow matrix. The `test` job generates 9 × 6 × 4 × 2 = 432 combinations. You need to reduce the matrix dimensions.
</details>

<details>
<summary>Hint 2</summary>
The `exclude` key expects a YAML list (with `-` prefix), not a single mapping. Each exclusion pattern should be a list item.
</details>

<details>
<summary>Hint 3</summary>
Docker Linux containers don't run natively on `windows-latest` runners. Either exclude Windows from the docker-build matrix or add Docker Desktop setup steps for Windows.
</details>

## 🔧 Issues to Fix

1. `test` matrix generates 432 jobs (exceeds 256 limit) — reduce platforms, versions, or databases
2. `exclude` syntax is wrong — needs to be a list with `-` prefix
3. `docker-build` includes `windows-latest` which can't run Linux Docker containers
4. `integration` matrix has 192 combinations — likely excessive for CI
5. Image tag uses platform name with slashes (`app:ubuntu-latest`) which is invalid for Docker tags
