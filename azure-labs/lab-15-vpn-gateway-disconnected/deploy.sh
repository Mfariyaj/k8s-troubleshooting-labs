#!/bin/bash
set -e
echo "🚀 Lab 15: vpn gateway disconnected"
echo "============================================================"
echo ""
echo "📋 Category: Networking"
echo "💰 Cost: bash.15"
echo "📋 Scenario: Site-to-Site VPN tunnel down: shared key mismatch"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.15" != "FREE" ] && echo "   Estimated cost: bash.15/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: Site-to-Site VPN tunnel down: shared key mismatch"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az network vpn-connection show -n <conn> -g <rg>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
