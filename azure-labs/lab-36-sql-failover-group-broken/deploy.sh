#!/bin/bash
set -e
echo "🚀 Lab 36: sql failover group broken"
echo "============================================================"
echo ""
echo "📋 Category: Database"
echo "💰 Cost: bash.04"
echo "📋 Scenario: Failover group secondary not syncing"
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
echo "🔧 SCENARIO: Failover group secondary not syncing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az sql failover-group show -n <fg> -g <rg> -s <server>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
