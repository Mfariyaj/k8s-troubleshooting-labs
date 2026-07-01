# Solution: Lab 07 - GitLab CI Stages and Dependencies

## Problem

GitLab CI pipeline jobs run in wrong order, fail with "undefined variable" errors
from missing dependencies, or skip jobs due to incorrect rules.

## Diagnosis

```bash
# Check the pipeline configuration
cat .gitlab-ci.yml

# Look for:
# - Stage order definition
# - needs: references to non-existent jobs
# - rules: conditions that prevent jobs from running
```

## Root Cause

1. **Wrong stage order**: The `stages:` list defines execution order — jobs in later
   stages wait for earlier stages. If deploy comes before test, tests are skipped.
2. **Wrong `needs:` references**: Job names in `needs:` don't match actual job names.
3. **Incorrect `rules:`**: Conditions prevent jobs from running (wrong branch name,
   wrong variable check).

## Fix

```yaml
# FIXED: Correct stage ordering
stages:
  - build
  - test
  - deploy

build-job:
  stage: build
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/

test-job:
  stage: test
  # FIXED: Reference correct job name
  needs: [build-job]  # Not "build" — must match exact job name
  script:
    - npm test

deploy-job:
  stage: deploy
  needs: [test-job]  # FIXED: correct reference
  script:
    - ./deploy.sh
  # FIXED: rules syntax
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: always
    - when: never
```

## Key Fixes

| Issue | Broken | Fixed |
|-------|--------|-------|
| Stage order | deploy before test | build → test → deploy |
| needs reference | `needs: [build]` | `needs: [build-job]` |
| Rules | `if: $CI_BRANCH == main` | `if: $CI_COMMIT_BRANCH == "main"` |

## Verification

- Pipeline stages execute in order: build → test → deploy
- Jobs correctly wait for their dependencies
- Deploy only runs on the main branch
- `needs:` enables DAG mode for faster parallel execution

## Key Takeaways

- `stages:` defines the ORDER, `stage:` assigns a job to a stage
- `needs:` must reference the exact job name (not the stage name)
- GitLab CI variables use `$CI_COMMIT_BRANCH` (not `$CI_BRANCH`)
- Use `rules:` instead of deprecated `only:`/`except:`
- Quote string comparisons in rules: `== "main"` not `== main`
