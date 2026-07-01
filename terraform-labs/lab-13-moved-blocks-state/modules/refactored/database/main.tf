# Refactored database module

variable "cluster_identifier" {
  description = "RDS cluster identifier"
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class for cluster instances"
  type        = string
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 2
}

resource "aws_rds_cluster" "main" {
  cluster_identifier = var.cluster_identifier
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version
  master_username    = "admin"
  master_password    = "CHANGE_ME_BEFORE_APPLY"

  skip_final_snapshot = true

  tags = {
    Name = var.cluster_identifier
  }
}

resource "aws_rds_cluster_instance" "instances" {
  count = var.instance_count

  identifier         = "${var.cluster_identifier}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
}

output "cluster_endpoint" {
  value = aws_rds_cluster.main.endpoint
}
