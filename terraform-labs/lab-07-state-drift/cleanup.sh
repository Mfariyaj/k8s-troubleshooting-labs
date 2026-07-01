#!/bin/bash
# Lab 07 - Cleanup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "  Cleaning up Lab 07 - State Drift..."
rm -rf "$WORK_DIR"
rm -rf "$SCRIPT_DIR/.terraform"
rm -f "$SCRIPT_DIR/.terraform.lock.hcl"
rm -f "$SCRIPT_DIR/terraform.tfstate*"
echo "  ✅ Lab 07 cleaned."
