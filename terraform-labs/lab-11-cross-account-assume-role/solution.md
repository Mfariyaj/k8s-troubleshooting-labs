## Solution: Cross-Account Assume Role

### Root Cause

Multiple IAM configuration errors prevent the cross-account role assumption:

1. **Wrong account ID in trust policy** — `111122224444` (typo) instead of `111122223333` (source account)
2. **Wrong action in trust policy** — `sts:TagSession` instead of `sts:AssumeRole`
3. **External ID mismatch** — trust policy uses `TerraformExternal2024` but provider sends `TerraformExternal2025`
4. **Session duration exceeds maximum** — provider requests `12h` (43200s) but role allows max `3600s` (1h)
5. **Source account policy references wrong role name** — `TerraformRole` instead of `TerraformCrossAccountRole`
6. **Permission boundary blocks S3/DynamoDB** — only allows EC2 and IAM read

### Step-by-Step Fix

Fix all IAM configuration files:

### Fixed Code (iam.tf — trust policy)

```hcl
resource "aws_iam_role" "terraform_cross_account" {
  provider = aws.target_account
  name     = "TerraformCrossAccountRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::111122223333:root"  # Fix 1: correct account ID
        }
        Action = "sts:AssumeRole"  # Fix 2: correct action
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "TerraformExternal2024"  # Fix 3: match this value
          }
        }
      }
    ]
  })

  max_session_duration = 43200  # Fix 4: increase to allow 12h sessions

  permissions_boundary = aws_iam_policy.permission_boundary.arn
  tags = { Purpose = "cross-account-terraform" }
}
```

### Fixed Code (providers.tf — match external_id)

```hcl
provider "aws" {
  alias  = "target_account"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::444455556666:role/TerraformCrossAccountRole"
    session_name = "TerraformCrossAccountSession"
    external_id  = "TerraformExternal2024"  # Fix 3: match trust policy
    duration     = "1h"                     # Fix 4: or reduce to fit role max
  }
}
```

### Fixed Code (iam.tf — source account policy)

```hcl
resource "aws_iam_policy" "allow_assume_target" {
  provider = aws.source_account
  name     = "AllowAssumeCrossAccountRole"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = "arn:aws:iam::444455556666:role/TerraformCrossAccountRole"  # Fix 5
    }]
  })
}
```

### Fixed Code (iam.tf — permission boundary: add S3 + DynamoDB)

```hcl
resource "aws_iam_policy" "permission_boundary" {
  provider = aws.target_account
  name     = "TerraformPermissionBoundary"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowRequiredServices"
        Effect   = "Allow"
        Action   = ["ec2:*", "s3:*", "dynamodb:*", "iam:Get*", "iam:List*"]  # Fix 6
        Resource = "*"
      }
    ]
  })
}
```

### Verification

```bash
# Test role assumption
aws sts assume-role \
  --role-arn arn:aws:iam::444455556666:role/TerraformCrossAccountRole \
  --role-session-name test \
  --external-id TerraformExternal2024

# Verify terraform can plan with the target account provider
terraform plan
```
