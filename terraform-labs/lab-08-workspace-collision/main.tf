terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # BUG: The key is STATIC - it doesn't include the workspace name!
  # Both "dev" and "staging" workspaces will write to the SAME state file,
  # overwriting each other's resources.
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "applications/web-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
    # MISSING: workspace_key_prefix or dynamic key with workspace name
    # Should be: key = "applications/web-app/${terraform.workspace}/terraform.tfstate"
    # Or add:    workspace_key_prefix = "applications/web-app"
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  environment = terraform.workspace
  instance_count = {
    dev     = 1
    staging = 2
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  count         = lookup(local.instance_count, local.environment, 1)
  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.environment == "staging" ? "t3.medium" : "t3.small"

  tags = {
    Name        = "web-app-${local.environment}-${count.index + 1}"
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "app" {
  name        = "web-app-${local.environment}-sg"
  description = "Security group for ${local.environment} web app"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-app-${local.environment}-sg"
    Environment = local.environment
  }
}

output "instance_ids" {
  value = aws_instance.app[*].id
}

output "environment" {
  value = local.environment
}
