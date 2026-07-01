#!/bin/bash
# Lab 06 - Cleanup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "  Cleaning up Lab 06 - Variable Validation..."
rm -rf "$WORK_DIR"
rm -rf "$SCRIPT_DIR/.terraform"
rm -f "$SCRIPT_DIR/.terraform.lock.hcl"
rm -f "$SCRIPT_DIR/terraform.tfstate*"
echo "  ✅ Lab 06 cleaned."
