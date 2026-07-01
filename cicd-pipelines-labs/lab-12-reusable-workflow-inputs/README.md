# Lab 12: GitHub Actions Reusable Workflow — Inputs, Secrets, and Outputs Broken

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your team has refactored the deployment pipeline to use GitHub Actions reusable workflows for DRY deployments across environments. The caller workflow invokes a reusable deploy workflow, but:

1. The staging deployment can't access secrets (KUBECONFIG, SLACK_WEBHOOK)
2. The migration step never runs despite being enabled
3. The production deployment can't get the image tag from staging output
4. Integration tests fail because they reference a non-existent job
5. The cluster-name input is always empty in the reusable workflow

Everything was working when it was a single monolithic workflow, but after the refactor it's completely broken.

## Error Output

```
Run ./.github/workflows/reusable-deploy.yml
  with:
    environment: staging
    image-tag: sha-a1b2c3d
    run-migrations: true              # ← type mismatch warning
    cluster-name:                     # ← empty! env context not available
    timeout: 300

Error: .github/workflows/caller.yml (Line 67)
  The workflow is not valid. .github/workflows/caller.yml (Line 67, Col 7):
  'deploy' is not a valid job name. Did you mean 'deploy-staging'?

Error: Input 'run-migrations' expected type 'string' but got 'boolean'

Warning: Secret source not available
  The secret 'KUBECONFIG' is not available because secrets were not inherited
  or explicitly passed to the reusable workflow.
```

```
Job: deploy-production
  Error evaluating expression: needs.deploy-staging.outputs.deployed-image
  Result: ''
  Note: The output 'deployed-image' was not found in job 'deploy-staging'
```

## Your Task

Fix all issues in both the caller and reusable workflow files:
1. Ensure secrets are passed to the reusable workflow
2. Fix the input type mismatch for `run-migrations`
3. Fix the output chain (job → workflow → caller)
4. Fix the `needs` context reference to the correct job name
5. Fix the env context issue (env vars from caller aren't available in called workflows)

## Hints

<details>
<summary>Hint 1</summary>
Add `secrets: inherit` to the `deploy-staging` job in caller.yml. Without this, the reusable workflow has zero access to repository or organization secrets. The env context from the caller is also never available inside a reusable workflow — you must pass values as explicit inputs instead.
</details>

<details>
<summary>Hint 2</summary>
The `needs: deploy` in the integration-tests job should be `needs: deploy-staging`. GitHub Actions job references must match the exact job ID key. Also, `run-migrations: true` passes a boolean but the input type is `string` — quote it as `"true"` or change the input type to `boolean`.
</details>

<details>
<summary>Hint 3</summary>
For outputs to flow from reusable workflow back to caller: The step must set an output → the job must declare that output → the workflow `outputs:` section must reference `jobs.<job-id>.outputs.<name>`. The names must match at each level. Check if `deployed-image` is consistent across step output, job output, and workflow output declarations.
</details>

## Useful Commands

```bash
# Examine the caller workflow
cat .github/workflows/caller.yml

# Examine the reusable workflow
cat .github/workflows/reusable-deploy.yml

# Validate workflow syntax locally with actionlint
actionlint .github/workflows/caller.yml
actionlint .github/workflows/reusable-deploy.yml

# Check for type mismatches
grep -n "type:" .github/workflows/reusable-deploy.yml

# Check secrets usage in reusable workflow
grep -n "secrets\." .github/workflows/reusable-deploy.yml

# Check output chain
grep -n "outputs" .github/workflows/caller.yml .github/workflows/reusable-deploy.yml

# Check needs references
grep -n "needs:" .github/workflows/caller.yml

# Check env context usage (not available in reusable workflows)
grep -n "env\." .github/workflows/caller.yml

# Validate with act (local GitHub Actions runner)
act --list

# Check GitHub Actions workflow syntax docs
# https://docs.github.com/en/actions/using-workflows/reusing-workflows

# Diff the two workflows to trace data flow
diff <(grep -E '(inputs|outputs|secrets|needs)' .github/workflows/caller.yml) \
     <(grep -E '(inputs|outputs|secrets|needs)' .github/workflows/reusable-deploy.yml)
```

## What You'll Learn

- Reusable workflow input/output contracts
- Secret inheritance vs explicit passing
- Type validation for workflow inputs
- Output chaining: step → job → workflow → caller
- Context availability differences between caller and called workflows
- Common refactoring mistakes when splitting monolithic workflows
