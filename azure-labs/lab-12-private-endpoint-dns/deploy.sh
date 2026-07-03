#!/bin/bash
set -e
echo "🚀 Lab 12: private endpoint dns"
echo "============================================================"
echo ""
echo "📋 Category: Networking"
echo "💰 Cost: bash.01"
echo "📋 Scenario: Private endpoint created but DNS not resolving to private IP"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.01" != "FREE" ] && echo "   Estimated cost: bash.01/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: Private endpoint created but DNS not resolving to private IP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az network private-dns zone list -g <rg>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
