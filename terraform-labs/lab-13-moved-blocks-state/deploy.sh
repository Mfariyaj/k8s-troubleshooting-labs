#!/bin/bash
# Lab 13: Moved Blocks and State Refactoring - Deploy Script

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-13-moved-blocks-state"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Lab 13: Moved Blocks & State Refactoring                   ║"
echo "║  Difficulty: EXPERT                                         ║"
echo "║  Estimated Time: 20-30 minutes                              ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Scenario: Refactoring from root-level count to modules     ║"
echo "║  with for_each. Moved blocks have wrong addresses causing   ║"
echo "║  production resources to be destroyed and recreated.        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$LAB_DIR"

# Simulate existing state (what would exist before refactoring)
echo "[1/4] Simulating pre-refactoring state..."
cat > terraform.tfstate << 'EOF'
{
  "version": 4,
  "terraform_version": "1.6.0",
  "serial": 42,
  "lineage": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "web",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "index_key": 0,
          "schema_version": 1,
          "attributes": {
            "id": "i-0abc123def456789a",
            "ami": "ami-0abcdef1234567890",
            "instance_type": "t3.large",
            "subnet_id": "subnet-0a1b2c3d",
            "tags": {"Name": "web-0", "Environment": "production"}
          }
        },
        {
          "index_key": 1,
          "schema_version": 1,
          "attributes": {
            "id": "i-0abc123def456789b",
            "ami": "ami-0abcdef1234567890",
            "instance_type": "t3.large",
            "subnet_id": "subnet-0e5f6a7b",
            "tags": {"Name": "web-1", "Environment": "production"}
          }
        },
        {
          "index_key": 2,
          "schema_version": 1,
          "attributes": {
            "id": "i-0abc123def456789c",
            "ami": "ami-0abcdef1234567890",
            "instance_type": "t3.large",
            "subnet_id": "subnet-0c8d9e0f",
            "tags": {"Name": "web-2", "Environment": "production"}
          }
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "data",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "index_key": 0,
          "schema_version": 0,
          "attributes": {
            "id": "company-data-bucket-0-444455556666",
            "bucket": "company-data-bucket-0-444455556666",
            "arn": "arn:aws:s3:::company-data-bucket-0-444455556666"
          }
        },
        {
          "index_key": 1,
          "schema_version": 0,
          "attributes": {
            "id": "company-data-bucket-1-444455556666",
            "bucket": "company-data-bucket-1-444455556666",
            "arn": "arn:aws:s3:::company-data-bucket-1-444455556666"
          }
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_rds_cluster",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "production-cluster",
            "cluster_identifier": "production-cluster",
            "engine": "aurora-postgresql",
            "engine_version": "15.3",
            "endpoint": "production-cluster.cluster-abc123.us-east-1.rds.amazonaws.com"
          }
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_iam_role",
      "name": "service",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "index_key": 0,
          "schema_version": 0,
          "attributes": {
            "id": "api-service",
            "name": "api-service",
            "arn": "arn:aws:iam::444455556666:role/api-service"
          }
        },
        {
          "index_key": 1,
          "schema_version": 0,
          "attributes": {
            "id": "worker-service",
            "name": "worker-service",
            "arn": "arn:aws:iam::444455556666:role/worker-service"
          }
        }
      ]
    }
  ],
  "check_results": null
}
EOF

echo "[2/4] Initializing Terraform..."
terraform init -input=false 2>&1 || true

echo ""
echo "[3/4] Running terraform plan (expect destroy/recreate instead of move)..."
echo "---------------------------------------------------"
terraform plan 2>&1 || true

echo ""
echo "---------------------------------------------------"
echo "[4/4] Lab deployed. Fix the moved blocks!"
echo ""
echo "Files to investigate:"
echo "  - main.tf                         (moved blocks with wrong addresses)"
echo "  - modules/refactored/*/main.tf    (target module structure)"
echo "  - terraform.tfstate               (current state — what exists)"
echo ""
echo "Key commands:"
echo "  terraform state list"
echo "  terraform plan -no-color 2>&1 | grep -E 'destroy|create|move'"
echo ""
echo "Goal: terraform plan should show 0 to add, 0 to destroy (all moved)"
echo "Good luck! 🔧"
