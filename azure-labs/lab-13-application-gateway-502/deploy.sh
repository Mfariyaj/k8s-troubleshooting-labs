#!/bin/bash
set -e
echo "🚀 Lab 13: application gateway 502"
echo "============================================================"
echo ""
echo "📋 Category: Networking"
echo "💰 Cost: bash.07"
echo "📋 Scenario: App Gateway 502 Bad Gateway: backend pool unhealthy"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.07" != "FREE" ] && echo "   Estimated cost: bash.07/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: App Gateway 502 Bad Gateway: backend pool unhealthy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az network application-gateway show-backend-health"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
