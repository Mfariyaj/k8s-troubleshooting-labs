# Lab 13: Moved Blocks and State Refactoring - Broken Configuration
# Resources are being refactored from root-level count-based to module-based for_each
# Moved blocks should prevent destroy/recreate but they have address issues

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

# ═══════════════════════════════════════════════════════════════
# MOVED BLOCKS - All have addressing issues
# ═══════════════════════════════════════════════════════════════

# BUG 1: 'from' references module.legacy which doesn't exist in state
# The instances are at root level: aws_instance.web[0], [1], [2]
# BUG 2: 'to' uses wrong for_each keys - module uses "web-0" but moved says "0"
moved {
  from = module.legacy.aws_instance.web[0]
  to   = module.compute.aws_instance.web["0"]
}

moved {
  from = module.legacy.aws_instance.web[1]
  to   = module.compute.aws_instance.web["1"]
}

moved {
  from = module.legacy.aws_instance.web[2]
  to   = module.compute.aws_instance.web["2"]
}

# BUG 3: from address has wrong module prefix 'module.storage_legacy'
# The S3 buckets are at root: aws_s3_bucket.data[0], [1]
# BUG 4: 'to' address missing the for_each key entirely
moved {
  from = module.storage_legacy.aws_s3_bucket.data[0]
  to   = module.storage.aws_s3_bucket.data
}

moved {
  from = module.storage_legacy.aws_s3_bucket.data[1]
  to   = module.storage.aws_s3_bucket.data
}

# BUG 5: 'from' references nested module path that doesn't exist
# The RDS cluster is at root: aws_rds_cluster.main
# BUG 6: Trying to move from a nested module path across packages
moved {
  from = module.databases.module.primary.aws_rds_cluster.main
  to   = module.database.aws_rds_cluster.main
}

# BUG 7: IAM roles moved block has count index in 'to' but module uses for_each
moved {
  from = aws_iam_role.service[0]
  to   = module.iam.aws_iam_role.service[0]
}

moved {
  from = aws_iam_role.service[1]
  to   = module.iam.aws_iam_role.service[1]
}

# ═══════════════════════════════════════════════════════════════
# NEW MODULE REFERENCES (the refactored structure)
# ═══════════════════════════════════════════════════════════════

module "compute" {
  # BUG 8: Wrong source path - should be ./modules/refactored/compute
  source = "./modules/refactored/servers"

  instance_names = {
    "web-0" = { instance_type = "t3.large", subnet_id = "subnet-0a1b2c3d" }
    "web-1" = { instance_type = "t3.large", subnet_id = "subnet-0e5f6a7b" }
    "web-2" = { instance_type = "t3.large", subnet_id = "subnet-0c8d9e0f" }
  }

  ami_id = "ami-0abcdef1234567890"
  tags = {
    Environment = "production"
    Team        = "platform"
  }
}

module "storage" {
  source = "./modules/refactored/storage"

  buckets = {
    "bucket-0" = { versioning = true, encryption = "AES256" }
    "bucket-1" = { versioning = true, encryption = "aws:kms" }
  }

  account_id = "444455556666"
}

module "database" {
  source = "./modules/refactored/database"

  cluster_identifier = "production-cluster"
  engine_version     = "15.3"
  instance_class     = "db.r6g.xlarge"
  instance_count     = 3
}

module "iam" {
  source = "./modules/refactored/iam"

  roles = {
    "api-service"    = { policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"] }
    "worker-service" = { policy_arns = ["arn:aws:iam::aws:policy/AmazonSQSFullAccess"] }
  }
}
