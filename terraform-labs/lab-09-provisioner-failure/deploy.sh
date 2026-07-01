#!/bin/bash
# Lab 09 - Provisioner Failure
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 09: Provisioner Failure (Tainted Resource)"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  An EC2 instance was created but the remote-exec provisioner"
echo "  failed (wrong SSH key path, timeout too short, missing script)."
echo "  The resource is now TAINTED in state. Running terraform apply"
echo "  will DESTROY and recreate the instance, causing downtime!"
echo ""
echo "=============================================="

# Create workspace
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Copy terraform files to workspace
cp "$SCRIPT_DIR/main.tf" "$WORK_DIR/"

# Create a simulated state file with a tainted resource
cat > "$WORK_DIR/terraform.tfstate" << 'EOF'
{
  "version": 4,
  "terraform_version": "1.5.7",
  "serial": 5,
  "lineage": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
  "outputs": {
    "instance_id": {
      "value": "i-0abc123def456789a",
      "type": "string"
    },
    "instance_private_ip": {
      "value": "10.0.1.47",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "data",
      "type": "aws_ami",
      "name": "amazon_linux",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "ami-0abc123def456789a",
            "name": "amzn2-ami-hvm-2.0.20240109.0-x86_64-gp2"
          }
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_key_pair",
      "name": "deployer",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "key_name": "deployer-key",
            "key_pair_id": "key-0abc123",
            "fingerprint": "ab:cd:ef:12:34:56:78:90"
          }
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_security_group",
      "name": "app",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "id": "sg-0abc123def456",
            "name": "app-server-sg",
            "vpc_id": "vpc-0abc123"
          }
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "app_server",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "status": "tainted",
          "schema_version": 1,
          "attributes": {
            "id": "i-0abc123def456789a",
            "ami": "ami-0abc123def456789a",
            "instance_type": "t3.large",
            "private_ip": "10.0.1.47",
            "subnet_id": "subnet-0abc123",
            "key_name": "deployer-key",
            "vpc_security_group_ids": ["sg-0abc123def456"],
            "tags": {
              "Name": "app-server-prod",
              "Environment": "production",
              "ManagedBy": "terraform"
            }
          }
        }
      ]
    }
  ],
  "check_results": null
}
EOF

echo ""
echo "  📁 Lab files created in: $WORK_DIR"
echo "  📄 State file includes a TAINTED aws_instance.app_server"
echo ""
echo "  TO REPRODUCE THE ERROR:"
echo "  ─────────────────────────────────────────"
echo "  cd $WORK_DIR"
echo "  terraform init"
echo "  terraform plan"
echo ""
echo "  You will see:"
echo "  'aws_instance.app_server is tainted, so must be replaced'"
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Understand why the instance is tainted"
echo "  2. Remove the taint (the instance is running fine)"
echo "  3. Fix the provisioner configuration"
echo "  4. Ensure terraform plan doesn't try to destroy the instance"
echo ""
echo "  HINT: terraform untaint <resource_address>"
echo ""
