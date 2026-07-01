# Solution: Lab 12 - Reusable Workflow Inputs

## Problem

Reusable workflows fail with "secrets not available", input type validation errors,
or caller workflows cannot access outputs from the reusable workflow.

## Diagnosis

```bash
# Check the caller workflow
cat .github/workflows/caller.yml

# Check the reusable workflow
cat .github/workflows/reusable-deploy.yml

# Look for:
# - Missing secrets: inherit
# - Input type mismatches (string vs boolean)
# - Outputs not properly exposed from jobs
```

## Root Cause

1. **Missing `secrets: inherit`**: Caller doesn't pass secrets to the reusable
   workflow, so `${{ secrets.* }}` is empty inside it.
2. **Wrong input types**: Input defined as `boolean` but caller passes a string, or
   vice versa — causes type validation failure.
3. **Output not exposed**: Reusable workflow job output isn't mapped to the workflow
   level `outputs:` section.

## Fix

### Caller workflow:

```yaml
jobs:
  deploy:
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: production
      # FIXED: Match the expected type (boolean, not string)
      dry-run: false  # Not "false" (string)
    # FIXED: Pass secrets to reusable workflow
    secrets: inherit
```

### Reusable workflow:

```yaml
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      dry-run:
        required: false
        # FIXED: Correct type declaration
        type: boolean
        default: false
    # Expose outputs from the reusable workflow
    outputs:
      deploy-url:
        description: "Deployment URL"
        value: ${{ jobs.deploy.outputs.url }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    # FIXED: Map job outputs
    outputs:
      url: ${{ steps.deploy.outputs.url }}
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        id: deploy
        run: |
          echo "url=https://${{ inputs.environment }}.example.com" >> $GITHUB_OUTPUT
```

## Key Fixes

| Issue | Broken | Fixed |
|-------|--------|-------|
| Secrets | Not passed | `secrets: inherit` |
| Input type | `type: string` for boolean | `type: boolean` |
| Output | Not exposed at workflow level | Add `outputs:` mapping |

## Verification

- Reusable workflow receives secrets successfully
- Boolean inputs work without type validation errors
- Caller workflow can read outputs from the reusable workflow

## Key Takeaways

- `secrets: inherit` passes all caller secrets to reusable workflows
- Input types must match exactly between caller and definition
- Outputs need two mappings: step→job (`outputs:`) and job→workflow (`outputs:`)
- Boolean inputs use `true`/`false` without quotes in the caller
