#!/bin/bash
# Clean up all Terraform troubleshooting labs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================="
echo "  🧹 Cleaning Up All Terraform Troubleshooting Labs"
echo "=============================================="
echo ""

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
  if [ -f "$lab_dir/cleanup.sh" ]; then
    echo "----------------------------------------------"
    echo "  Cleaning: $(basename "$lab_dir")"
    echo "----------------------------------------------"
    bash "$lab_dir/cleanup.sh"
    echo ""
  fi
done

echo "=============================================="
echo "  ✅ All labs cleaned up!"
echo "=============================================="
