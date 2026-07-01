# Lab 04: Artifact Passing Between Jobs

## 🎯 Scenario

A multi-job pipeline builds an application, runs tests, deploys to staging, and executes smoke tests. However, artifacts aren't being passed correctly between jobs. The test job can't find the build output, the smoke-test job references an artifact that was never uploaded, and the retention settings are causing issues.

## 🔴 Difficulty: Medium

## 📋 Error Output

GitHub Actions shows:

```
Job 'test' failed:
  Run actions/download-artifact@v4
  Error: Unable to find any artifacts for the associated workflow run.
  Looking for artifact: 'build-artifacts'
  Available artifacts: 'build-output'
  
  This job does not have a 'needs' dependency on the 'build' job.
  Artifacts from other jobs are only available if the job declares a dependency.

Job 'build' warning:
  Run actions/upload-artifact@v4
  Warning: Invalid retention-days value '0'. Minimum is 1, maximum is 90.
  Defaulting to repository/organization setting.

Job 'smoke-test' failed:
  Run actions/download-artifact@v4
  Error: Unable to find any artifacts for the associated workflow run.
  Looking for artifact: 'test-results'
  No artifact with name 'test-results' was uploaded by any job in this workflow run.
```

## 🐛 Debugging Steps

1. Compare artifact names between upload and download:
   ```
   Upload: name: build-output
   Download: name: build-artifacts  ← MISMATCH!
   ```

2. Check job dependencies (`needs:`):
   ```
   test job: no 'needs' keyword → runs in parallel with build
   ```

3. Verify retention-days value:
   ```
   retention-days: 0 → Invalid! Minimum is 1
   ```

4. Check if 'test-results' artifact is ever uploaded (it's not!)

## 💡 Hints

<details>
<summary>Hint 1</summary>
The `test` job downloads an artifact called `build-artifacts` but the `build` job uploads it as `build-output`. Names must match exactly.
</details>

<details>
<summary>Hint 2</summary>
The `test` job has no `needs: [build]` declaration, so it starts immediately in parallel with `build`. The artifact won't exist yet when `test` tries to download it.
</details>

<details>
<summary>Hint 3</summary>
The `smoke-test` job tries to download `test-results` but no job ever uploads an artifact with that name. Also, `retention-days: 0` is invalid — minimum is 1.
</details>

## 🔧 Issues to Fix

1. Artifact name mismatch: `build-output` (upload) vs `build-artifacts` (download)
2. Missing `needs: [build]` in the `test` job — runs in parallel so artifact doesn't exist
3. `retention-days: 0` is invalid — must be between 1 and 90
4. `smoke-test` downloads `test-results` which is never uploaded by any job
5. `test` job references `build-artifacts/` directory but download goes to current directory by default
