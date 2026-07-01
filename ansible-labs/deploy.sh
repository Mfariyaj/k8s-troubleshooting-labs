#!/bin/bash
echo "============================================"
echo "  Ansible Troubleshooting Labs - Deploy All"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
    if [ -f "$lab_dir/deploy.sh" ]; then
        echo "-------------------------------------------"
        echo "Deploying: $(basename "$lab_dir")"
        echo "-------------------------------------------"
        cd "$lab_dir" && bash deploy.sh
        echo ""
    fi
done

echo "============================================"
echo "  All labs deployed!"
echo "============================================"
