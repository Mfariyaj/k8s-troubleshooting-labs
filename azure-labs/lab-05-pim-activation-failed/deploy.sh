#!/bin/bash
set -e
echo "🚀 Lab 05: pim activation failed"
echo "============================================================"
echo ""
echo "📋 Category: Identity"
echo "💰 Cost: FREE"
echo "📋 Scenario: PIM eligible role activation fails: justification required"
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
echo "🔧 SCENARIO: PIM eligible role activation fails: justification required"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az rest --method POST --url 'https://graph.microsoft.com/...'"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
