#!/bin/bash
# Deploy all Git troubleshooting labs
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Deploying all Git troubleshooting labs..."
echo "============================================="

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
    if [ -f "$lab_dir/deploy.sh" ]; then
        lab_name=$(basename "$lab_dir")
        echo ""
        echo "📦 Deploying: $lab_name"
        echo "-------------------------------------------"
        bash "$lab_dir/deploy.sh"
    fi
done

echo ""
echo "============================================="
echo "✅ All labs deployed!"
echo ""
echo "Lab repositories created in /tmp/git-lab-*/"
echo "Run 'ls /tmp/git-lab-*' to see all lab directories."
