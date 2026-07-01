# Lab 15: Large State Performance Degradation - Broken Configuration
# This configuration has architectural issues causing 45+ minute plan times

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

# PERFORMANCE ISSUE 1: Data sources evaluated on EVERY plan
# These make API calls to AWS on every terraform plan/apply

# BUG: This AMI lookup takes 3-5 seconds and runs on every plan
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# BUG: These lookups are called from EVERY module instance too
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["production-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}

# PERFORMANCE ISSUE 2: Per-service data sources (20x expensive lookups)
locals {
  services = {
    "api-gateway"       = { cpu = 512, memory = 1024, port = 8080, replicas = 3 }
    "user-service"      = { cpu = 256, memory = 512, port = 8080, replicas = 2 }
    "order-service"     = { cpu = 512, memory = 1024, port = 8080, replicas = 3 }
    "payment-service"   = { cpu = 512, memory = 1024, port = 8080, replicas = 2 }
    "inventory-service" = { cpu = 256, memory = 512, port = 8080, replicas = 2 }
    "notification-svc"  = { cpu = 128, memory = 256, port = 8080, replicas = 1 }
    "analytics-service" = { cpu = 1024, memory = 2048, port = 8080, replicas = 2 }
    "search-service"    = { cpu = 512, memory = 1024, port = 8080, replicas = 2 }
    "auth-service"      = { cpu = 256, memory = 512, port = 8080, replicas = 3 }
    "email-service"     = { cpu = 128, memory = 256, port = 8080, replicas = 1 }
    "report-service"    = { cpu = 256, memory = 512, port = 8080, replicas = 1 }
    "config-service"    = { cpu = 128, memory = 256, port = 8080, replicas = 2 }
    "gateway-internal"  = { cpu = 256, memory = 512, port = 8080, replicas = 2 }
    "scheduler-service" = { cpu = 256, memory = 512, port = 8080, replicas = 1 }
    "audit-service"     = { cpu = 256, memory = 512, port = 8080, replicas = 2 }
    "billing-service"   = { cpu = 512, memory = 1024, port = 8080, replicas = 2 }
    "catalog-service"   = { cpu = 256, memory = 512, port = 8080, replicas = 2 }
    "shipping-service"  = { cpu = 256, memory = 512, port = 8080, replicas = 2 }
    "recommendation-sv" = { cpu = 1024, memory = 2048, port = 8080, replicas = 2 }
    "media-service"     = { cpu = 512, memory = 1024, port = 8080, replicas = 2 }
  }

  # BUG: Deprecated services still referenced - state entries are orphaned
  deprecated_services = [
    "service-deprecated-01",
    "service-deprecated-02",
    "service-deprecated-03",
    "service-deprecated-04",
    "service-deprecated-05",
    "service-deprecated-06",
    "service-deprecated-07",
    "service-deprecated-08",
  ]
}

# BUG: These data sources evaluated for EACH service on every plan
# Each aws_secretsmanager_secret_version call takes 2-3s due to throttling
data "aws_secretsmanager_secret_version" "service_secrets" {
  for_each  = local.services
  secret_id = "production/${each.key}/config"
}

# BUG: Policy documents generated per service - could be templated once
data "aws_iam_policy_document" "service_task_policy" {
  for_each = local.services

  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:us-east-1:*:secret:production/${each.key}/*"]
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::company-artifacts-*/${each.key}/*"]
  }
}

# BUG: ALB lookups for each service - expensive API calls multiplied
data "aws_lb" "service_alb" {
  for_each = local.services
  name     = "${each.key}-alb"
}

# PERFORMANCE ISSUE 3: Module called 20+ times with for_each
# Each module instance duplicates internal data source lookups

module "microservice" {
  source   = "./modules/microservice"
  for_each = local.services

  service_name = each.key
  cpu          = each.value.cpu
  memory       = each.value.memory
  port         = each.value.port
  replicas     = each.value.replicas

  vpc_id     = data.aws_vpc.main.id
  subnet_ids = data.aws_subnets.private.ids

  # Each module invocation triggers its own data source lookups
  ami_id           = data.aws_ami.latest_ubuntu.id
  secret_arn       = data.aws_secretsmanager_secret_version.service_secrets[each.key].arn
  task_policy_json = data.aws_iam_policy_document.service_task_policy[each.key].json
  alb_arn          = data.aws_lb.service_alb[each.key].arn

  tags = {
    Service     = each.key
    Environment = "production"
    Team        = "platform"
  }
}

# PERFORMANCE ISSUE 4: No use of -parallelism or -target
# Default parallelism=10 is too low for 2000+ resources

output "service_endpoints" {
  value = { for k, v in module.microservice : k => v.endpoint }
}

output "total_resources" {
  description = "Total resources managed - should trigger alarm if > 1500"
  value       = "Run: terraform state list | wc -l"
}
