#!/bin/bash
set -e
echo "🚀 Lab 02: service principal expired"
echo "============================================================"
echo ""
echo "📋 Category: Identity"
echo "💰 Cost: FREE"
echo "📋 Scenario: Service Principal client secret expired, app auth fails"
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
echo "🔧 SCENARIO: Service Principal client secret expired, app auth fails"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az ad sp credential list --id <app-id>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
