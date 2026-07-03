#!/bin/bash
set -e
echo "🚀 Lab 11: vnet peering broken"
echo "============================================================"
echo ""
echo "📋 Category: Networking"
echo "💰 Cost: FREE"
echo "📋 Scenario: VNet peering status Connected but traffic not flowing"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "FREE" != "FREE" ] && echo "   Estimated cost: FREE/hour — run cleanup.sh when done!"
echo ""
read -p "Continue? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

# Verify Azure login
if ! az account show &>/dev/null; then
  echo "❌ Not logged in! Run: az login"
  exit 1
fi

SUB=$(az account show --query name -o tsv)
echo ""
echo "✅ Subscription: $SUB"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 SCENARIO: VNet peering status Connected but traffic not flowing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az network vnet peering list --vnet-name <vnet> -g <rg>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
