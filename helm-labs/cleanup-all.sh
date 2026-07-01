#!/bin/bash
# Cleanup all Helm troubleshooting labs

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LABS=$(find "$SCRIPT_DIR" -maxdepth 1 -type d -name "lab-*" | sort)

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          Helm Troubleshooting Labs - Cleanup All            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

for lab_dir in $LABS; do
    lab_name=$(basename "$lab_dir")

    if [ -x "$lab_dir/cleanup.sh" ]; then
        echo "🧹 Cleaning: $lab_name"
        (cd "$lab_dir" && ./cleanup.sh)
    else
        echo "⚠️  No cleanup.sh found in $lab_name"
    fi
done

echo ""
echo "✅ All labs cleaned up!"
