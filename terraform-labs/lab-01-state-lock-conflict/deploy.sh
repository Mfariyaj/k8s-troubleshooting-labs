#!/bin/bash
# Lab 01 - State Lock Conflict
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 01: State Lock Conflict"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  Your teammate John was running 'terraform apply' on the production"
echo "  network infrastructure when his laptop crashed. The DynamoDB state"
echo "  lock was never released. Now you cannot run any terraform commands."
echo ""
echo "=============================================="

# Create workspace
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Copy terraform files to workspace
cp "$SCRIPT_DIR/main.tf" "$WORK_DIR/"
cp "$SCRIPT_DIR/backend.tf" "$WORK_DIR/"

# Simulate a stuck lock by creating a mock lock info file
cat > "$WORK_DIR/LOCK_INFO.json" << 'EOF'
{
  "ID": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "Operation": "OperationTypeApply",
  "Info": "",
  "Who": "john.doe@laptop-abc",
  "Version": "1.5.7",
  "Created": "2024-01-15T14:23:45.123456Z",
  "Path": "s3://mycompany-terraform-state/prod/network/terraform.tfstate"
}
EOF

echo ""
echo "  📁 Lab files created in: $WORK_DIR"
echo ""
echo "  TO REPRODUCE THE ERROR:"
echo "  ─────────────────────────────────────────"
echo "  cd $WORK_DIR"
echo "  terraform init"
echo "  terraform plan"
echo ""
echo "  You will see an error like:"
echo "  'Error: Error acquiring the state lock'"
echo "  with Lock ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890"
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Identify the stale lock"
echo "  2. Verify the lock holder is no longer running"
echo "  3. Force-unlock the state"
echo "  4. Confirm terraform plan works again"
echo ""
echo "  HINT: Check 'terraform force-unlock --help'"
echo ""
