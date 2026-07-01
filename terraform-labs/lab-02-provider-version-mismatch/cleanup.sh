#!/bin/bash
# Lab 02 - Cleanup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "  Cleaning up Lab 02 - Provider Version Mismatch..."
rm -rf "$WORK_DIR"
rm -rf "$SCRIPT_DIR/.terraform"
rm -f "$SCRIPT_DIR/terraform.tfstate*"
echo "  ✅ Lab 02 cleaned."
