#!/bin/bash
# Lab 11: Cross-Account Assume Role - Cleanup Script

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up Lab 11: Cross-Account Assume Role..."

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
rm -f crash.log

echo "Lab 11 cleanup complete."
