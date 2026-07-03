#!/bin/bash
set -e
echo "🚀 Lab 08: key vault access denied"
echo "============================================================"
echo ""
echo "📋 Category: Identity"
echo "💰 Cost: bash.03"
echo "📋 Scenario: Key Vault RBAC vs Access Policy mode conflict"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.03" != "FREE" ] && echo "   Estimated cost: bash.03/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: Key Vault RBAC vs Access Policy mode conflict"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az keyvault show -n <kv> --query properties.enableRbacAuthorization"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
