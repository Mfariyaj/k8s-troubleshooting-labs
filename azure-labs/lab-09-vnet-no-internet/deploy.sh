#!/bin/bash
set -e
echo "🚀 Lab 09: vnet no internet"
echo "============================================================"
echo ""
echo "📋 Category: Networking"
echo "💰 Cost: bash.04"
echo "📋 Scenario: VM in VNet can't reach internet: no NAT Gateway/Public IP"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.04" != "FREE" ] && echo "   Estimated cost: bash.04/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: VM in VNet can't reach internet: no NAT Gateway/Public IP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az network nic show-effective-route-table"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
