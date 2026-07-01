terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # BUG: This backend references a bucket defined BELOW in this same config
  # The bucket doesn't exist yet, so terraform init will fail!
  backend "s3" {
    bucket         = "my-new-terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-new-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# The state bucket - defined here but referenced as backend above
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-new-terraform-state-bucket"

  tags = {
    Name        = "Terraform State Bucket"
    ManagedBy   = "terraform"
    Environment = "shared"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# The lock table - also defined here but referenced as backend above
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "my-new-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "Terraform Lock Table"
    ManagedBy = "terraform"
  }
}
