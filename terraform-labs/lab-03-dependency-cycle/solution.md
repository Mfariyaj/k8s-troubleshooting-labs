## Solution: Dependency Cycle

### Root Cause

The `aws_security_group.app` references `aws_instance.web_server.private_ip` in its ingress rule, while `aws_instance.web_server` references `aws_security_group.app.id` in `vpc_security_group_ids`. This creates a circular dependency:

```
Error: Cycle: aws_security_group.app, aws_instance.web_server
```

Terraform cannot determine which resource to create first since each depends on the other.

### Step-by-Step Fix

1. Remove the self-referencing ingress rule from the security group
2. Use a separate `aws_security_group_rule` resource that references the instance after creation, OR use `self = true` if the intent is to allow the instance to talk to itself

### Fixed Code (main.tf)

```hcl
resource "aws_security_group" "app" {
  name        = "app-server-sg"
  description = "Security group for the application server"
  vpc_id      = "vpc-0abc123def456"

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

# Separate rule added AFTER instance exists — breaks the cycle
resource "aws_security_group_rule" "allow_self" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.web_server.private_ip}/32"]
  security_group_id = aws_security_group.app.id
  description       = "Allow traffic from the web server itself"
}
```

### Verification

```bash
# Validate there are no cycles
terraform validate

# Plan should succeed without cycle errors
terraform plan

# Check the dependency graph
terraform graph | grep -i cycle
```
