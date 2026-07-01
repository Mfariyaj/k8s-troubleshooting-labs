#!/bin/bash
# Lab 03 - Dependency Cycle
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 03: Dependency Cycle"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  A junior engineer wrote Terraform for an EC2 instance with a"
echo "  security group. The security group references the instance's"
echo "  private IP, and the instance references the security group."
echo "  This creates a circular dependency that Terraform cannot resolve."
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
echo "  terraform validate"
echo ""
echo "  You will see an error like:"
echo "  'Error: Cycle: aws_security_group.app, aws_instance.web_server'"
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Identify the circular dependency"
echo "  2. Break the cycle by restructuring the resources"
echo "  3. Ensure terraform validate passes"
echo ""
echo "  HINT: Use a separate aws_security_group_rule resource"
echo ""
