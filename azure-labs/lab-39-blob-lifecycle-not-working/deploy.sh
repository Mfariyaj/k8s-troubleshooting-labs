#!/bin/bash
set -e
echo "🚀 Lab 39: blob lifecycle not working"
echo "============================================================"
echo ""
echo "📋 Category: Database"
echo "💰 Cost: bash.001"
echo "📋 Scenario: Lifecycle policy not transitioning blobs to cool tier"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.001" != "FREE" ] && echo "   Estimated cost: bash.001/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: Lifecycle policy not transitioning blobs to cool tier"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az storage account management-policy show -n <sa> -g <rg>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
