#!/bin/bash
# Lab 14: Provider Crash - Cleanup Script

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up Lab 14: Provider Crash..."

cd "$LAB_DIR"

# Clean up Terraform files
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -f crash.log
rm -f plan.tfplan

echo "Lab 14 cleanup complete."
