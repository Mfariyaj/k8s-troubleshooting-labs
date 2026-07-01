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

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# BUG: This security group references the instance's private IP
# creating a circular dependency
resource "aws_security_group" "app" {
  name        = "app-server-sg"
  description = "Security group for the application server"
  vpc_id      = "vpc-0abc123def456"

  # This ingress rule references the instance, creating a CYCLE
  ingress {
    description = "Allow traffic from the web server itself"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.web_server.private_ip}/32"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-server-sg"
  }
}

# This instance references the security group, completing the CYCLE
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = "subnet-0abc123"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "web-server-prod"
    Environment = "production"
  }
}

output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "security_group_id" {
  value = aws_security_group.app.id
}
