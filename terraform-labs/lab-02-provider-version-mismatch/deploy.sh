#!/bin/bash
# Lab 02 - Provider Version Mismatch
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 02: Provider Version Mismatch"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  Your CI/CD pipeline suddenly started failing on 'terraform init'."
echo "  A teammate committed changes to .terraform.lock.hcl that updated"
echo "  the AWS provider to 5.31.0, but versions.tf still pins to 4.67.0."
echo ""
echo "=============================================="

# Create workspace
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Copy terraform files to workspace
cp "$SCRIPT_DIR/main.tf" "$WORK_DIR/"
cp "$SCRIPT_DIR/versions.tf" "$WORK_DIR/"
cp "$SCRIPT_DIR/.terraform.lock.hcl" "$WORK_DIR/"

echo ""
echo "  📁 Lab files created in: $WORK_DIR"
echo ""
echo "  TO REPRODUCE THE ERROR:"
echo "  ─────────────────────────────────────────"
echo "  cd $WORK_DIR"
echo "  terraform init"
echo ""
echo "  You will see an error like:"
echo "  'locked provider registry.terraform.io/hashicorp/aws 5.31.0"
echo "   does not match configured version constraint = 4.67.0'"
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Understand why the lock file and constraint disagree"
echo "  2. Fix the version constraint or update the lock file"
echo "  3. Ensure terraform init succeeds"
echo ""
echo "  HINT: Check 'terraform init -upgrade' or fix versions.tf"
echo ""
