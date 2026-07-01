#!/bin/bash
# Lab 04 - Remote Backend Bootstrap
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 04: Remote Backend Bootstrap (Chicken-and-Egg)"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  A new team member defined the S3 backend bucket and DynamoDB"
echo "  lock table in the SAME Terraform config that uses them as"
echo "  the backend. terraform init fails because the bucket doesn't"
echo "  exist yet - but you can't create it without init!"
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
echo "  You will see an error like:"
echo "  'Error: Failed to get existing workspaces'"
echo "  'S3 bucket \"my-new-terraform-state-bucket\" does not exist.'"
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Understand the chicken-and-egg problem"
echo "  2. Bootstrap the backend (comment out backend, create resources, migrate)"
echo "  3. Ensure the full configuration works end-to-end"
echo ""
echo "  HINT: You can temporarily use local state to create the backend resources"
echo ""
