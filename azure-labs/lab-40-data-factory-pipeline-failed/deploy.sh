#!/bin/bash
set -e
echo "🚀 Lab 40: data factory pipeline failed"
echo "============================================================"
echo ""
echo "📋 Category: Database"
echo "💰 Cost: bash.01"
echo "📋 Scenario: ADF: linked service auth failed, mapping data flow error"
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
echo "🔧 SCENARIO: ADF: linked service auth failed, mapping data flow error"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az datafactory pipeline-run query-by-factory"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
