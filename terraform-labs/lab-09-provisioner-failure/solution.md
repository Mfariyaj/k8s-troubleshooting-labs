## Solution: Provisioner Failure

### Root Cause

The `remote-exec` and `file` provisioners on `aws_instance.app_server` fail because:

1. `private_key = file("/nonexistent/path/to/deployer-key.pem")` — path doesn't exist
2. `timeout = "30s"` — too short for instance to become SSH-ready
3. `source = "/nonexistent/scripts/setup-monitoring.sh"` — file doesn't exist

When a provisioner fails, Terraform marks the resource as **tainted**. On next `apply`, it will **destroy and recreate** the instance — potentially causing data loss.

### Step-by-Step Fix

**Immediate fix (resource is tainted):**

```bash
# Option A: Remove taint and fix the provisioner config, then re-apply
terraform untaint aws_instance.app_server

# Option B: Remove from state and re-import (preserves instance)
terraform state rm aws_instance.app_server
terraform import aws_instance.app_server i-0abc123def456

# Then fix the config and apply
terraform apply
```

**Fix the configuration to prevent recurrence:**

```bash
# 1. Generate a real key pair
ssh-keygen -t rsa -b 4096 -f ./deployer-key.pem -N ""

# 2. Create the monitoring script
mkdir -p scripts
cat > scripts/setup-monitoring.sh << 'EOF'
#!/bin/bash
echo "Setting up monitoring agent..."
EOF

# 3. Update main.tf with corrected provisioner (see below)
terraform apply
```

### Fixed Code (main.tf — provisioner section)

```hcl
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

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/deployer-key.pem")  # Fix: valid local path
    host        = self.private_ip
    timeout     = "5m"  # Fix: allow enough time for SSH to become ready
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

  provisioner "file" {
    source      = "${path.module}/scripts/setup-monitoring.sh"  # Fix: valid path
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
```

### Verification

```bash
# Confirm instance is not tainted
terraform plan
# Should NOT show "forces replacement"

# Apply successfully
terraform apply

# Verify instance is running
aws ec2 describe-instances --instance-ids $(terraform output -raw instance_id) \
  --query 'Reservations[0].Instances[0].State.Name'
```
