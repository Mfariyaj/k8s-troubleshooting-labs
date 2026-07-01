#!/bin/bash
# Lab 08 - Workspace State Collision
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 08: Workspace State Collision"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  Your team uses Terraform workspaces for dev and staging."
echo "  The backend config uses a STATIC key path that doesn't"
echo "  include the workspace name. Both workspaces write to the"
echo "  same state file, overwriting each other!"
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
echo "  terraform workspace new dev"
echo "  terraform plan            # Plan for dev"
echo "  terraform workspace new staging"
echo "  terraform plan            # Plan for staging - same state!"
echo ""
echo "  Both workspaces will read/write the SAME state file."
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Identify why both workspaces share state"
echo "  2. Fix the backend config to isolate workspace state"
echo "  3. Verify each workspace has independent state"
echo ""
echo "  HINT: Look at the 'key' in the backend block"
echo ""
