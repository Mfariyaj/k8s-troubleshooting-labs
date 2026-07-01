#!/bin/bash
# Deploy all Terraform troubleshooting labs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================="
echo "  🔧 Deploying All Terraform Troubleshooting Labs"
echo "=============================================="
echo ""

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
  if [ -f "$lab_dir/deploy.sh" ]; then
    echo "----------------------------------------------"
    echo "  Deploying: $(basename "$lab_dir")"
    echo "----------------------------------------------"
    bash "$lab_dir/deploy.sh"
    echo ""
  fi
done

echo "=============================================="
echo "  ✅ All labs deployed!"
echo "  Run cleanup-all.sh when finished."
echo "=============================================="
