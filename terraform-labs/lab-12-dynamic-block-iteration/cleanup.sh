#!/bin/bash
# Lab 12: Dynamic Block Iteration - Cleanup Script

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up Lab 12: Dynamic Block Iteration..."

cd "$LAB_DIR"

# Destroy any created resources
if [ -f "terraform.tfstate" ]; then
  echo "Destroying Terraform resources..."
  terraform destroy -auto-approve 2>/dev/null || true
fi

# Clean up Terraform files
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -f plan.tfplan
rm -f crash.log

echo "Lab 12 cleanup complete."
