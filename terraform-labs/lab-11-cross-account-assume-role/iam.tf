# IAM Role and Trust Policy in the Target Account
# This would normally be applied separately in the target account first

# The cross-account role that Terraform assumes
resource "aws_iam_role" "terraform_cross_account" {
  provider = aws.target_account
  name     = "TerraformCrossAccountRole"

  # BUG: Wrong account ID - should be 111122223333 (source) but has 111122224444 (typo)
  # BUG: Missing sts:AssumeRole - only has sts:TagSession which is insufficient
  # BUG: external_id is "TerraformExternal2024" but provider uses "TerraformExternal2025"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::111122224444:root"
        }
        Action = "sts:TagSession"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "TerraformExternal2024"
          }
        }
      }
    ]
  })

  # BUG: max_session_duration is 3600 (1 hour) but provider requests 12 hours (43200)
  max_session_duration = 3600

  # Permission boundary that restricts what the role can do
  permissions_boundary = aws_iam_policy.permission_boundary.arn

  tags = {
    Purpose     = "cross-account-terraform"
    Environment = "production"
  }
}

# Permission boundary - overly restrictive, blocks S3 and DynamoDB actions needed
resource "aws_iam_policy" "permission_boundary" {
  provider    = aws.target_account
  name        = "TerraformPermissionBoundary"
  description = "Permission boundary for cross-account Terraform role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2Only"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDangerous"
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:DeleteRole",
          "organizations:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy attached to the role - but permission boundary blocks S3/DynamoDB
resource "aws_iam_role_policy" "terraform_access" {
  provider = aws.target_account
  name     = "TerraformResourceAccess"
  role     = aws_iam_role.terraform_cross_account.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketVersioning",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:PutBucketTagging",
          "s3:GetBucketTagging"
        ]
        Resource = "*"
      },
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:ListTagsOfResource"
        ]
        Resource = "*"
      }
    ]
  })
}

# The source account needs a policy allowing sts:AssumeRole
resource "aws_iam_policy" "allow_assume_target" {
  provider    = aws.source_account
  name        = "AllowAssumeCrossAccountRole"
  description = "Allows assuming role in target account"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAssumeRole"
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        # BUG: Resource ARN has wrong role name (TerraformRole vs TerraformCrossAccountRole)
        Resource = "arn:aws:iam::444455556666:role/TerraformRole"
      }
    ]
  })
}
