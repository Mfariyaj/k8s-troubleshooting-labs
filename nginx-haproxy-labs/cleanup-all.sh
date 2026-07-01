#!/bin/bash
# Clean up all Nginx/HAProxy troubleshooting labs

echo "🧹 Cleaning up all Nginx/HAProxy troubleshooting labs..."
echo "=================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
  if [ -f "$lab_dir/cleanup.sh" ]; then
    lab_name=$(basename "$lab_dir")
    echo ""
    echo "🗑️  Cleaning up $lab_name..."
    echo "--------------------------------------------------"
    (cd "$lab_dir" && bash cleanup.sh)
    if [ $? -eq 0 ]; then
      echo "✅ $lab_name cleaned up"
    else
      echo "⚠️  $lab_name cleanup had issues"
    fi
  fi
done

echo ""
echo "=================================================="
echo "✅ All labs cleaned up!"
echo "=================================================="
