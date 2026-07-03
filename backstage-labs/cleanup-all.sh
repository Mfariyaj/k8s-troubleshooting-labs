#!/bin/bash
echo "🧹 Cleaning up all labs..."
for lab in lab-*/; do
  cd "$lab" && bash cleanup.sh 2>/dev/null && cd ..
done
echo "✅ All cleaned up"
