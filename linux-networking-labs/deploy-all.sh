#!/bin/bash
# Deploy all Linux/Networking troubleshooting labs
# Usage: sudo bash deploy-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Deploying All Linux/Networking Labs"
echo "=========================================="

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
    if [ -f "$lab_dir/deploy.sh" ]; then
        lab_name=$(basename "$lab_dir")
        echo ""
        echo "--- Deploying: $lab_name ---"
        bash "$lab_dir/deploy.sh"
        echo "--- $lab_name deployed ---"
    fi
done

echo ""
echo "=========================================="
echo "  All labs deployed successfully!"
echo "  Start troubleshooting with:"
echo "    cd lab-01-disk-full"
echo "    # Investigate the issue..."
echo "=========================================="
