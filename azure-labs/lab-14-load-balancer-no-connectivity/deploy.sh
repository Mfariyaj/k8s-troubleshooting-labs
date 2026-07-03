#!/bin/bash
set -e
echo "🚀 Lab 14: load balancer no connectivity"
echo "============================================================"
echo ""
echo "📋 Category: Networking"
echo "💰 Cost: bash.03"
echo "📋 Scenario: Load Balancer health probe failing: wrong port/path"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.03" != "FREE" ] && echo "   Estimated cost: bash.03/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: Load Balancer health probe failing: wrong port/path"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az network lb probe list --lb-name <lb> -g <rg>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
