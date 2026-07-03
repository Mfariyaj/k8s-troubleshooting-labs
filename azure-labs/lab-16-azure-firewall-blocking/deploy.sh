#!/bin/bash
set -e
echo "🚀 Lab 16: azure firewall blocking"
echo "============================================================"
echo ""
echo "📋 Category: Networking"
echo "💰 Cost: bash.13"
echo "📋 Scenario: Azure Firewall application rule blocking HTTPS traffic"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.13" != "FREE" ] && echo "   Estimated cost: bash.13/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: Azure Firewall application rule blocking HTTPS traffic"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az network firewall application-rule list -g <rg> -f <fw>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
