#!/bin/bash
# Deploy all Python troubleshooting labs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Python Troubleshooting Labs - Deploy All"
echo "=========================================="
echo ""

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
    if [ -f "$lab_dir/deploy.sh" ]; then
        lab_name=$(basename "$lab_dir")
        echo "📦 Deploying: $lab_name"
        bash "$lab_dir/deploy.sh"
        echo ""
        echo "------------------------------------------"
        echo ""
    fi
done

echo "=========================================="
echo "  All labs deployed!"
echo "  Lab files are in /tmp/python-lab-*/"
echo "=========================================="
