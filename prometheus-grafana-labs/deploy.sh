#!/bin/bash
echo "🚀 Deploying ALL Prometheus/Grafana Troubleshooting Labs..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
  if [ -f "$lab_dir/deploy.sh" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Deploying: $(basename "$lab_dir")"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    bash "$lab_dir/deploy.sh"
    echo ""
  fi
done

echo "✅ All labs deployed!"
echo ""
echo "⚠️  NOTE: Labs share common ports (9090, 3000, 9093)."
echo "   Deploy one lab at a time, or modify ports to avoid conflicts."
