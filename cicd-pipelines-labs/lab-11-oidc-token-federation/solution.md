# Solution: Lab 11 - OIDC Token Federation

## Problem

GitHub Actions workflow fails to assume an AWS IAM role via OIDC with errors like
"Not authorized to perform sts:AssumeRoleWithWebIdentity" or token validation failures.

## Diagnosis

```bash
# Check the workflow
cat .github/workflows/deploy.yml

# Check the IAM role trust policy
cat terraform/iam-role.tf

# Look for:
# - Wrong audience in trust policy
# - Subject claim format mismatch
# - Missing id-token: write permission
```

## Root Cause

1. **Wrong audience**: Trust policy specifies wrong audience value. For GitHub OIDC
   with AWS, it must be `sts.amazonaws.com`.
2. **Wrong subject claim format**: The `sub` condition in the trust policy doesn't
   match GitHub's format: `repo:OWNER/REPO:ref:refs/heads/BRANCH`.
3. **Missing `id-token: write`**: The workflow lacks permission to request OIDC tokens.

## Fix

### Step 1: Fix the workflow permissions

```yaml
permissions:
  contents: read
  # FIXED: Required for OIDC token generation
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
          aws-region: us-east-1
          # FIXED: audience defaults to sts.amazonaws.com (correct for AWS)
```

### Step 2: Fix the IAM trust policy

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:ref:refs/heads/main"
      }
    }
  }]
}
```

## Key Fixes

| Issue | Broken | Fixed |
|-------|--------|-------|
| Audience | `github.com` | `sts.amazonaws.com` |
| Subject | `repo:myorg/myrepo:*` | `repo:myorg/myrepo:ref:refs/heads/main` |
| Permission | Missing | `id-token: write` |

## Verification

- Workflow successfully assumes the IAM role
- AWS CLI commands work within the job
- Token audience and subject match the trust policy conditions

## Key Takeaways

- AWS OIDC audience must be `sts.amazonaws.com` (not `github.com`)
- Subject format: `repo:OWNER/REPO:ref:refs/heads/BRANCH`
- `id-token: write` permission is mandatory for OIDC token requests
- Use `StringLike` with wildcards for multiple branches/environments
