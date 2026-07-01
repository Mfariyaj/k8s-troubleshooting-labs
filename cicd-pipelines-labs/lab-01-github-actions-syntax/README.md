# Lab 01: GitHub Actions Syntax Errors

## 🎯 Scenario

Your team's new developer pushed a GitHub Actions workflow file but the pipeline refuses to run. GitHub shows a workflow file error and no jobs are triggered. The developer insists "the YAML looks fine" but clearly something is very wrong with the syntax.

## 🔴 Difficulty: Easy

## 📋 Error Output

When pushing to the repository, GitHub shows:

```
Error: .github/workflows/broken-ci.yml (Line 3, Col 3): 'push_request' is not a valid event name.
Error: .github/workflows/broken-ci.yml (Line 5, Col 3): 'pull' is not a valid event name.
Error: .github/workflows/broken-ci.yml (Line 11, Col 3): 'steps' is not a valid job property at this indentation level.
Error: .github/workflows/broken-ci.yml (Line 12, Col 7): Must specify a version for action 'actions/checkout'. Example: actions/checkout@v4
Error: .github/workflows/broken-ci.yml (Line 14, Col 7): Must specify a version for action 'actions/setup-node'. Example: actions/setup-node@v4
Error: .github/workflows/broken-ci.yml (Line 18, Col 9): Unexpected scalar value 'run' at this position.
Error: .github/workflows/broken-ci.yml (Line 29, Col 8): Wrong indentation: expected 6, got 7.
```

The workflow never executes. No jobs appear in the Actions tab.

## 🐛 Debugging Steps

1. Check the workflow YAML syntax:
   ```bash
   actionlint .github/workflows/broken-ci.yml
   ```

2. Validate YAML structure:
   ```bash
   yamllint .github/workflows/broken-ci.yml
   ```

3. Check GitHub Actions documentation for valid event names:
   - Valid push events: `push`, `pull_request`, `pull_request_target`
   - NOT: `push_request`, `pull`

4. Verify job structure — `steps` must be nested under the job, not at the same level

5. Check all action references include version tags (e.g., `@v4`)

## 💡 Hints

<details>
<summary>Hint 1</summary>
The event triggers use invalid names. What are the correct GitHub event names for push and pull request triggers?
</details>

<details>
<summary>Hint 2</summary>
Look at the indentation of `steps:` in the build job. Is it inside the job or at the same level? Also check line 18 — `run:` has extra indentation.
</details>

<details>
<summary>Hint 3</summary>
Every `uses:` directive must include a version tag like `@v4`. Check actions/checkout and actions/setup-node.
</details>

## 🔧 Issues to Fix

1. Invalid event trigger names (`push_request` → `push`, `pull` → `pull_request`)
2. `steps:` is at wrong indentation level (should be under `build:` job)
3. `uses: actions/checkout` missing `@v4` version tag
4. `uses: actions/setup-node` missing `@v4` version tag
5. `run: npm ci` has wrong indentation (extra spaces)
6. Lint job has inconsistent step indentation
