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
  region = var.region
}

# BUG 1: Wrong registry namespace - "hashicorp-fake" doesn't exist
module "vpc" {
  source  = "hashicorp-fake/vpc/aws"
  version = "5.1.0"

  name = "prod-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "production"
  }
}

# BUG 2: Git repository doesn't exist and ref tag is impossible
module "networking" {
  source = "git::https://github.com/nonexistent-org/terraform-aws-network.git?ref=v99.0.0"

  vpc_id     = module.vpc.vpc_id
  create_igw = true
}

# BUG 3: Version constraint impossible - no module has version >= 99.0.0
module "compute" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 99.0.0"

  name          = "web-server"
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnets[0]

  tags = {
    Environment = "production"
  }
}

# BUG 4: Local module path doesn't exist
module "monitoring" {
  source = "./modules/monitoring-stack"

  enable_alerts = true
  sns_topic_arn = "arn:aws:sns:us-east-1:123456789:alerts"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
