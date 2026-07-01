#!/bin/bash
# Lab 04 - Cleanup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "  Cleaning up Lab 04 - Backend Bootstrap..."
rm -rf "$WORK_DIR"
rm -rf "$SCRIPT_DIR/.terraform"
rm -f "$SCRIPT_DIR/.terraform.lock.hcl"
rm -f "$SCRIPT_DIR/terraform.tfstate*"
echo "  ✅ Lab 04 cleaned."
