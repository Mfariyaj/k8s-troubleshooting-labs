#!/bin/bash
# Lab 07 - State Drift
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 07: State Drift"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  During an emergency, someone manually changed the production"
echo "  RDS instance in the AWS console:"
echo "    - Upgraded instance class: db.t3.medium → db.r5.xlarge"
echo "    - Disabled Multi-AZ (to speed up the change)"
echo "    - Reduced backup retention: 7 days → 3 days"
echo ""
echo "  Now terraform plan wants to REVERT all those changes!"
echo ""
echo "=============================================="

# Create workspace
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Copy terraform files to workspace
cp "$SCRIPT_DIR/main.tf" "$WORK_DIR/"
# Copy the drifted state file as the current state
cp "$SCRIPT_DIR/terraform.tfstate.drift" "$WORK_DIR/terraform.tfstate"

echo ""
echo "  📁 Lab files created in: $WORK_DIR"
echo ""
echo "  TO REPRODUCE THE ERROR:"
echo "  ─────────────────────────────────────────"
echo "  cd $WORK_DIR"
echo "  terraform init"
echo "  terraform plan"
echo ""
echo "  You will see Terraform wants to change the RDS instance"
echo "  BACK to what's in the code (reverting the emergency changes)."
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Understand the drift between code and state"
echo "  2. Decide: update code to match reality, or revert reality"
echo "  3. If updating code: modify main.tf to match current state"
echo "  4. Ensure terraform plan shows 'No changes'"
echo ""
echo "  HINT: Compare the values in main.tf with terraform.tfstate"
echo ""
