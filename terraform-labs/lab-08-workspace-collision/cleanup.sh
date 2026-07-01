#!/bin/bash
# Lab 08 - Cleanup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "  Cleaning up Lab 08 - Workspace Collision..."
rm -rf "$WORK_DIR"
rm -rf "$SCRIPT_DIR/.terraform"
rm -f "$SCRIPT_DIR/.terraform.lock.hcl"
rm -f "$SCRIPT_DIR/terraform.tfstate*"
rm -rf "$SCRIPT_DIR/terraform.tfstate.d"
echo "  ✅ Lab 08 cleaned."
