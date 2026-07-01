# Lab 11: Cross-Account Assume Role - Broken Configuration
# This lab simulates a multi-account AWS setup where Terraform needs to
# manage resources in a target account by assuming a role.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create an S3 bucket in the target account using the assumed role
resource "aws_s3_bucket" "cross_account_data" {
  provider = aws.target_account
  bucket   = "company-data-lake-${data.aws_caller_identity.target.account_id}"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform-cross-account"
  }
}

resource "aws_s3_bucket_versioning" "cross_account_data" {
  provider = aws.target_account
  bucket   = aws_s3_bucket.cross_account_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Create a DynamoDB table in target account
resource "aws_dynamodb_table" "cross_account_state_lock" {
  provider     = aws.target_account
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "production"
    Purpose     = "terraform-state-locking"
  }
}

# Data source to verify identity in target account
data "aws_caller_identity" "target" {
  provider = aws.target_account
}

data "aws_caller_identity" "source" {
  provider = aws.source_account
}

output "target_account_id" {
  value = data.aws_caller_identity.target.account_id
}

output "assumed_role_arn" {
  value = data.aws_caller_identity.target.arn
}
