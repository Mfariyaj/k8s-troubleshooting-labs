#!/bin/bash
set -e
echo "🚀 Lab 18: front door routing wrong"
echo "============================================================"
echo ""
echo "📋 Category: Networking"
echo "💰 Cost: bash.04"
echo "📋 Scenario: Front Door routing requests to wrong backend origin"
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
echo "🔧 SCENARIO: Front Door routing requests to wrong backend origin"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az afd route list --profile-name <fd> -g <rg>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
