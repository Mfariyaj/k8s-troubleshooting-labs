#!/bin/bash
# Lab 05 - Module Source Not Found
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 05: Module Source Not Found"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  After a repository restructure, module source paths were updated"
echo "  incorrectly. You have a wrong registry namespace, a non-existent"
echo "  git repository, an impossible version constraint, and a missing"
echo "  local module path. terraform init fails to download modules."
echo ""
echo "=============================================="

# Create workspace
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Copy terraform files to workspace
cp "$SCRIPT_DIR/main.tf" "$WORK_DIR/"

echo ""
echo "  📁 Lab files created in: $WORK_DIR"
echo ""
echo "  TO REPRODUCE THE ERROR:"
echo "  ─────────────────────────────────────────"
echo "  cd $WORK_DIR"
echo "  terraform init"
echo ""
echo "  You will see multiple module-related errors."
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Identify all broken module sources"
echo "  2. Fix registry namespace, git URL, version constraints"
echo "  3. Create or fix local module path"
echo "  4. Ensure terraform init downloads all modules"
echo ""
echo "  HINT: The correct VPC module is 'terraform-aws-modules/vpc/aws'"
echo ""
