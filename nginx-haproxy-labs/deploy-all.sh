#!/bin/bash
# Deploy all Nginx/HAProxy troubleshooting labs

echo "🚀 Deploying all Nginx/HAProxy troubleshooting labs..."
echo "=================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
  if [ -f "$lab_dir/deploy.sh" ]; then
    lab_name=$(basename "$lab_dir")
    echo ""
    echo "📦 Deploying $lab_name..."
    echo "--------------------------------------------------"
    (cd "$lab_dir" && bash deploy.sh)
    if [ $? -eq 0 ]; then
      echo "✅ $lab_name deployed successfully"
    else
      echo "❌ $lab_name deployment failed"
    fi
  fi
done

echo ""
echo "=================================================="
echo "✅ All labs deployed! Start troubleshooting!"
echo "=================================================="
