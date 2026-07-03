#!/bin/bash
set -e
echo "🚀 Lab 33: storage account access denied"
echo "============================================================"
echo ""
echo "📋 Category: Database"
echo "💰 Cost: bash.001"
echo "📋 Scenario: Storage Account: SAS expired, firewall blocking VNet"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.001" != "FREE" ] && echo "   Estimated cost: bash.001/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: Storage Account: SAS expired, firewall blocking VNet"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az storage account show -n <storage>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
