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

# This is what Terraform THINKS the resource should look like.
# But the real AWS resource has been manually changed to:
#   instance_class = "db.r5.xlarge"  (was "db.t3.medium")
#   multi_az = false                  (was true)
#   backup_retention_period = 3       (was 7)
resource "aws_db_instance" "production" {
  identifier     = "prod-app-database"
  engine         = "postgres"
  engine_version = "15.4"

  # The code says t3.medium, but someone changed it to r5.xlarge in the console
  instance_class = "db.t3.medium"

  allocated_storage     = 100
  max_allocated_storage = 500
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "appdb"
  username = "admin"
  password = "PLACEHOLDER_CHANGE_ME"

  # Code says multi_az = true, but it was disabled manually
  multi_az = true

  # Code says 7 days, but someone changed to 3 in emergency
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  vpc_security_group_ids = ["sg-0abc123def456"]
  db_subnet_group_name   = "prod-db-subnets"

  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "prod-app-database-final"

  performance_insights_enabled = true

  tags = {
    Name        = "prod-app-database"
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "terraform"
  }
}

resource "aws_db_instance" "replica" {
  identifier          = "prod-app-database-replica"
  replicate_source_db = aws_db_instance.production.identifier
  instance_class      = "db.t3.medium"

  vpc_security_group_ids = ["sg-0abc123def456"]

  tags = {
    Name        = "prod-app-database-replica"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

output "db_endpoint" {
  value = aws_db_instance.production.endpoint
}

output "db_replica_endpoint" {
  value = aws_db_instance.replica.endpoint
}
