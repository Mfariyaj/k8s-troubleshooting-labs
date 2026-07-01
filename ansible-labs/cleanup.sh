#!/bin/bash
echo "============================================"
echo "  Ansible Troubleshooting Labs - Cleanup All"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
    if [ -f "$lab_dir/cleanup.sh" ]; then
        echo "-------------------------------------------"
        echo "Cleaning: $(basename "$lab_dir")"
        echo "-------------------------------------------"
        cd "$lab_dir" && bash cleanup.sh
        echo ""
    fi
done

echo "============================================"
echo "  All labs cleaned up!"
echo "============================================"
