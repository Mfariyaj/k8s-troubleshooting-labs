#!/bin/bash
# Deploy all Helm troubleshooting labs
# Each lab shows its specific error/issue

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LABS=$(find "$SCRIPT_DIR" -maxdepth 1 -type d -name "lab-*" | sort)

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          Helm Troubleshooting Labs - Deploy All             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

TOTAL=0
SUCCESS=0
FAILED=0

for lab_dir in $LABS; do
    lab_name=$(basename "$lab_dir")
    TOTAL=$((TOTAL + 1))

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Running: $lab_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -x "$lab_dir/deploy.sh" ]; then
        (cd "$lab_dir" && ./deploy.sh)
        if [ $? -eq 0 ]; then
            SUCCESS=$((SUCCESS + 1))
        else
            FAILED=$((FAILED + 1))
        fi
    else
        echo "⚠️  No deploy.sh found or not executable in $lab_name"
        FAILED=$((FAILED + 1))
    fi

    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: $TOTAL labs executed ($SUCCESS showed errors as expected, $FAILED had issues)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
