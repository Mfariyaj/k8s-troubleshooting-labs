#!/bin/bash
# Deploy all Docker troubleshooting labs
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🐳 Deploying all Docker Troubleshooting Labs..."
echo "================================================"

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
    if [ -f "$lab_dir/deploy.sh" ]; then
        lab_name=$(basename "$lab_dir")
        echo ""
        echo "📦 Deploying $lab_name..."
        echo "---"
        cd "$lab_dir"
        bash deploy.sh || echo "⚠️  $lab_name deploy showed errors (expected - it's broken!)"
        cd "$SCRIPT_DIR"
    fi
done

echo ""
echo "================================================"
echo "✅ All labs deployed! Start troubleshooting."
echo "Use 'docker ps -a' to see running/failed containers."
