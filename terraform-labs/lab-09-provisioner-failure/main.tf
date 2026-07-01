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

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7fake..."
}

resource "aws_security_group" "app" {
  name        = "app-server-sg"
  description = "Security group for app server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.large"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = "subnet-0abc123"

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  # BUG: This provisioner will FAIL because:
  # 1. The private_key path doesn't exist
  # 2. The timeout is too short for instance to become SSH-ready
  # 3. The script path is wrong
  # When it fails, the instance gets TAINTED and will be DESTROYED on next apply
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/nonexistent/path/to/deployer-key.pem")
    host        = self.private_ip
    timeout     = "30s"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker pull mycompany/app:latest",
      "sudo docker run -d -p 8080:8080 mycompany/app:latest",
    ]
  }

  # This script also doesn't exist
  provisioner "file" {
    source      = "/nonexistent/scripts/setup-monitoring.sh"
    destination = "/tmp/setup-monitoring.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-monitoring.sh",
      "sudo /tmp/setup-monitoring.sh"
    ]
  }

  tags = {
    Name        = "app-server-prod"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

output "instance_id" {
  value = aws_instance.app_server.id
}

output "instance_private_ip" {
  value = aws_instance.app_server.private_ip
}
