#!/bin/bash
echo "🧹 Cleaning up ALL Prometheus/Grafana Troubleshooting Labs..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
  if [ -f "$lab_dir/cleanup.sh" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🗑️  Cleaning: $(basename "$lab_dir")"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    bash "$lab_dir/cleanup.sh"
    echo ""
  fi
done

echo "✅ All labs cleaned up!"
