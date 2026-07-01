#!/bin/bash
# Clean up all Docker troubleshooting labs
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧹 Cleaning up all Docker Troubleshooting Labs..."
echo "================================================"

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
    if [ -f "$lab_dir/cleanup.sh" ]; then
        lab_name=$(basename "$lab_dir")
        echo ""
        echo "🗑️  Cleaning $lab_name..."
        cd "$lab_dir"
        bash cleanup.sh 2>/dev/null || true
        cd "$SCRIPT_DIR"
    fi
done

echo ""
echo "================================================"
echo "✅ All labs cleaned up!"
