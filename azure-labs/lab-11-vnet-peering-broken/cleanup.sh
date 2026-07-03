#!/bin/bash
echo "🧹 Cleaning up..."
# Delete resource group if created
RG=$(cat /tmp/azure-lab-rg 2>/dev/null)
[ -n "$RG" ] && az group delete -n "$RG" --yes --no-wait 2>/dev/null
echo "✅ Cleaned up"
