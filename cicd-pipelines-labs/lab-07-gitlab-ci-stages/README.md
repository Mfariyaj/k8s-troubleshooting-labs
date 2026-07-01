# Lab 07: GitLab CI Stages & Dependencies

## 🎯 Scenario

A team migrated their CI/CD pipeline to GitLab CI but the pipeline is failing with multiple errors. Stages are in the wrong order, job dependencies reference non-existent jobs, artifacts aren't being passed correctly, and rule conditions create conflicts that prevent jobs from running.

## 🔴 Difficulty: Medium

## 📋 Error Output

GitLab CI shows:

```
Pipeline failed:

Error: 'unit_tests' job: needs 'build_application' which does not exist.
  Available jobs: build_app, unit_tests, integration_tests, lint, deploy_staging, deploy_production
  Did you mean 'build_app'?

Error: stages order conflict:
  Defined stages: deploy, test, build
  Job 'deploy_staging' (stage: deploy) needs 'unit_tests' (stage: test)
  Job 'unit_tests' (stage: test) needs 'build_app' (stage: build)
  
  Stage execution order: deploy → test → build
  But dependency order requires: build → test → deploy
  
  Jobs in 'deploy' stage would run BEFORE their dependencies in 'test' and 'build' stages!

Warning: 'integration_tests' job expects artifacts from 'build_app' but 'build_app' 
  artifacts are only available within the same stage unless explicitly downloaded.
  The 'needs' keyword handles this, but verify paths match.

Error: 'lint' job has conflicting rules:
  Rule 1: if '$CI_PIPELINE_SOURCE == "push"' → when: always
  Rule 2: if '$CI_PIPELINE_SOURCE == "push"' → when: never
  First matching rule wins — Rule 2 will never execute.
  However, this indicates a logic error in the pipeline configuration.

Warning: 'deploy_production' needs 'deploy_staging' but both are in 'deploy' stage.
  'needs' across jobs in the same stage may create circular dependencies.
```

## 🐛 Debugging Steps

1. Check stage ordering:
   ```yaml
   stages:
     - deploy  # ← Should be LAST
     - test    # ← Should be SECOND
     - build   # ← Should be FIRST
   ```

2. Verify job `needs:` references match actual job names:
   ```
   needs: build_application → Should be: build_app
   ```

3. Check for conflicting rules:
   ```yaml
   # lint job has two rules for same condition with opposite 'when' values
   rules:
     - if: '$CI_PIPELINE_SOURCE == "push"' when: always
     - if: '$CI_PIPELINE_SOURCE == "push"' when: never  # ← Unreachable!
   ```

4. Verify artifact passing between stages with `needs:`

## 💡 Hints

<details>
<summary>Hint 1</summary>
Stages are defined as: deploy, test, build. This means deploy runs FIRST, then test, then build. The correct order should be: build, test, deploy.
</details>

<details>
<summary>Hint 2</summary>
The `unit_tests` job has `needs: build_application` but the actual job name is `build_app`. Job names in `needs` must exactly match the job key in the YAML.
</details>

<details>
<summary>Hint 3</summary>
The `lint` job has two rules with the same condition (`$CI_PIPELINE_SOURCE == "push"`) but different `when` values. GitLab CI uses first-match-wins, so the second rule is unreachable. Also check if the second condition was meant for a different source.
</details>

## 🔧 Issues to Fix

1. Stages order is reversed: `deploy, test, build` → should be `build, test, deploy`
2. `unit_tests` references `build_application` in needs — should be `build_app`
3. `lint` job has conflicting rules (same condition, different `when` values)
4. `deploy_production` and `deploy_staging` are in same stage with `needs` dependency between them
5. `integration_tests` expects `dist/` from artifacts but needs proper path configuration
6. `unit_tests` rules conflict: `when: always` for push + `when: never` for MR + fallback `when: always`
