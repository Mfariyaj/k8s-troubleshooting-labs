## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a git repo with broken workflow)
2. Review the broken workflow YAML (.github/workflows/ or .gitlab-ci.yml)
3. Identify the syntax errors, logic issues, or misconfiguration
4. Fix the workflow file
5. Validate with: `actionlint` (GitHub Actions) or CI Lint API (GitLab)
6. Check `solution.md` if stuck

---

# Lab 09: Conditional Execution Logic

## 🎯 Scenario

The team configured conditional pipeline execution to only build and deploy when relevant files change. However, the conditions aren't working as expected — the pipeline either never triggers, always triggers regardless of changes, or skips important jobs. The logic errors span both GitHub Actions and GitLab CI.

## 🔴 Difficulty: Hard

## 📋 Error Output

### GitHub Actions:

```
Workflow 'Conditional Pipeline' did not trigger on push to main.
  Reason: paths filter only matches 'docs/**' and '*.md'
  Push modified: src/api/server.ts, src/components/App.tsx
  No paths matched — workflow skipped entirely.

Job 'build-backend' skipped:
  Condition: needs.detect-changes.outputs.backend_changed == 'true'
  Actual output name: 'backend' (not 'backend_changed')
  Output value: undefined → condition is false → job skipped

Job 'build-frontend' skipped:
  Condition: needs.detect-changes.outputs.frontend-changed == true
  Issue: Comparing string output to boolean 'true' (no quotes)
  'true' (string) == true (boolean) → false in expression evaluation

Job 'deploy' ran despite build jobs being skipped:
  Condition: always()
  The always() function makes this job run even when dependencies are skipped/failed.
  Deploy should NOT run if no builds completed.

Job 'notify' skipped:
  Condition: github.event.pusher.name == 'admin'
  Actual pusher: 'developer-1'
  This condition is too restrictive — should check organization role, not username.
```

### GitLab CI:

```
Job 'build-backend' created but will never run:
  Rule 1: if '$SOURCE_CHANGED == true' → variable comparison without quotes
    GitLab compares string "true" to bareword true — may not match
  Rule 2: if '$CI_COMMIT_BRANCH == "main"' when: never
    On main branch, this rule matches FIRST (rules are evaluated top-to-bottom)
    The job will NEVER run on main because rule 2 always matches!

Job 'deploy-canary' always runs:
  Last rule: 'when: always' with no condition
  This acts as a catch-all — deploy-canary runs on EVERY pipeline!
  
Job 'deploy' blocked by DEPLOY_ENABLED="false":
  Rule 3: if '$DEPLOY_ENABLED == "false"' when: never
  This matches because DEPLOY_ENABLED defaults to "false"
  Even manual trigger on main is blocked because rule evaluation is sequential
```

## 🐛 Debugging Steps

1. Check workflow `paths` filter — does it include the paths being modified?
2. Verify output variable names match between producer and consumer jobs
3. Check string vs boolean comparison in `if:` conditions
4. Understand `always()` behavior — it runs the job even if dependencies fail/skip
5. GitLab: rules are evaluated top-to-bottom, first match wins
6. Check for catch-all `when: always` at end of rules list

## 💡 Hints

<details>
<summary>Hint 1</summary>
The workflow `paths` filter only includes `docs/**` and `*.md`. When source code files change (src/), the workflow never triggers! You need to include source paths OR remove the paths filter.
</details>

<details>
<summary>Hint 2</summary>
In GitHub Actions, job outputs are strings. Comparing `== true` (boolean) instead of `== 'true'` (string) will fail. Also check that output names match exactly (underscores vs hyphens).
</details>

<details>
<summary>Hint 3</summary>
In GitLab CI, `when: always` without a condition at the end of rules acts as a catch-all — the job runs on every pipeline. In GitHub Actions, `if: always()` makes a job run even when all dependencies were skipped.
</details>

## 🔧 Issues to Fix

### GitHub Actions:
1. `paths` filter only matches docs — source code changes don't trigger the workflow
2. Output name mismatch: `backend_changed` vs actual name `backend`
3. String comparison: `== true` should be `== 'true'` (outputs are always strings)
4. `if: always()` on deploy means it runs even when build jobs are skipped
5. `notify` condition checks exact username — too brittle

### GitLab CI:
1. `build-backend` rule order: `when: never` for main matches before changes rule
2. `$SOURCE_CHANGED == true` — should be `== "true"` (string comparison)
3. `deploy-canary` has `when: always` catch-all — runs on every pipeline
4. `deploy` blocked by `DEPLOY_ENABLED == "false"` matching before manual rule
5. `build-frontend` has conflicting rules (manual for push, always for MR, then never)
