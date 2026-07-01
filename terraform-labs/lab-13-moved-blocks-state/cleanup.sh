#!/bin/bash
# Lab 13: Moved Blocks and State Refactoring - Cleanup Script

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up Lab 13: Moved Blocks and State Refactoring..."

cd "$LAB_DIR"

# Remove state file (it was simulated)
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -f plan-output.txt

# Clean up Terraform files
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f crash.log

echo "Lab 13 cleanup complete."
