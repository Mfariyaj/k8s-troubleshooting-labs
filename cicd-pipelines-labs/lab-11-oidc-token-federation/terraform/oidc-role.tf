# GitHub Actions OIDC Federation IAM Role
# This role allows GitHub Actions to assume AWS credentials via OIDC
#
# MULTIPLE BUGS IN THIS CONFIGURATION:
# 1. Audience condition uses "sigstore" instead of "sts.amazonaws.com"
# 2. Subject claim format is wrong (uses wrong owner/repo)
# 3. StringEquals used instead of StringLike (prevents wildcard matching)
# 4. MaxSessionDuration is 3600s but workflow requests 7200s

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# OIDC Provider (assuming already created)
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_deploy" {
  name = "github-actions-deploy"

  # BUG: MaxSessionDuration is 3600 (1 hour) but workflow requests 7200 (2 hours)
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          # BUG: Using StringEquals - this prevents wildcard patterns
          # Should use StringLike if wildcard matching is needed
          StringEquals = {
            # BUG: Audience is "sigstore" but aws-actions/configure-aws-credentials
            # sends "sts.amazonaws.com" as the default audience
            "token.actions.githubusercontent.com:aud" = "sigstore"

            # BUG: Subject claim format is wrong
            # Actual token sends: repo:acme-corp/infra-deploy:ref:refs/heads/main
            # This condition uses wrong org name and wrong format
            "token.actions.githubusercontent.com:sub" = "repo:acme-org/infrastructure:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Purpose     = "GitHub Actions OIDC Federation"
    Repository  = "acme-corp/infra-deploy"
    ManagedBy   = "terraform"
  }
}

# Deployment policy
resource "aws_iam_role_policy_attachment" "deploy_policy" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Output the role ARN
output "role_arn" {
  value       = aws_iam_role.github_actions_deploy.arn
  description = "ARN of the GitHub Actions deployment role"
}

output "trust_policy" {
  value       = aws_iam_role.github_actions_deploy.assume_role_policy
  description = "Trust policy document"
}
