#!/bin/bash
set -e
echo "🚀 Lab 34: cosmos db request throttled"
echo "============================================================"
echo ""
echo "📋 Category: Database"
echo "💰 Cost: bash.05"
echo "📋 Scenario: Cosmos DB 429: RU/s exceeded, hot partition"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.05" != "FREE" ] && echo "   Estimated cost: bash.05/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: Cosmos DB 429: RU/s exceeded, hot partition"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az cosmosdb show -n <cosmos> -g <rg>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
