#!/bin/bash
# Clean up all Linux/Networking troubleshooting labs
# Usage: sudo bash cleanup-all.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Cleaning Up All Linux/Networking Labs"
echo "=========================================="

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
    if [ -f "$lab_dir/cleanup.sh" ]; then
        lab_name=$(basename "$lab_dir")
        echo ""
        echo "--- Cleaning: $lab_name ---"
        bash "$lab_dir/cleanup.sh" 2>/dev/null || true
        echo "--- $lab_name cleaned ---"
    fi
done

echo ""
echo "=========================================="
echo "  All labs cleaned up successfully!"
echo "=========================================="
