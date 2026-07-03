#!/bin/bash
set -e
echo "🚀 Lab 06: custom role too restrictive"
echo "============================================================"
echo ""
echo "📋 Category: Identity"
echo "💰 Cost: FREE"
echo "📋 Scenario: Custom role missing Microsoft.Compute/virtualMachines/start/action"
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
echo "🔧 SCENARIO: Custom role missing Microsoft.Compute/virtualMachines/start/action"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az role definition list --custom-role-only"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
