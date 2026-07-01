#!/bin/bash
# Lab 06 - Variable Validation Failures
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 06: Variable Validation Failures"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  Your team enforces strict variable validations. A new deployment"
echo "  fails because terraform.tfvars contains values that violate"
echo "  multiple validation rules including wrong types, invalid"
echo "  formats, and out-of-range values."
echo ""
echo "=============================================="

# Create workspace
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Copy terraform files to workspace
cp "$SCRIPT_DIR/main.tf" "$WORK_DIR/"
cp "$SCRIPT_DIR/variables.tf" "$WORK_DIR/"
cp "$SCRIPT_DIR/terraform.tfvars" "$WORK_DIR/"

echo ""
echo "  📁 Lab files created in: $WORK_DIR"
echo ""
echo "  TO REPRODUCE THE ERROR:"
echo "  ─────────────────────────────────────────"
echo "  cd $WORK_DIR"
echo "  terraform init"
echo "  terraform plan"
echo ""
echo "  You will see multiple validation errors."
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Read the validation rules in variables.tf"
echo "  2. Identify all violations in terraform.tfvars"
echo "  3. Fix each value to pass validation"
echo "  4. Ensure terraform plan succeeds"
echo ""
echo "  HINT: There are 7 bugs in terraform.tfvars"
echo ""
