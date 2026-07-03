#!/bin/bash
echo "🧹 Cleaning up ALL Azure lab resources..."
for lab in lab-*/; do
  cd "$lab" && bash cleanup.sh 2>/dev/null && cd ..
done
# Also delete any lab resource groups
for rg in $(az group list --query "[?starts_with(name, 'lab-')].name" -o tsv 2>/dev/null); do
  echo "   Deleting RG: $rg"
  az group delete -n "$rg" --yes --no-wait 2>/dev/null
done
echo "✅ All Azure lab resources cleaned up!"
