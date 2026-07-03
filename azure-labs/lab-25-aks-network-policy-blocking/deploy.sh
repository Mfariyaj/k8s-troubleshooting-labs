#!/bin/bash
set -e
echo "🚀 Lab 25: aks network policy blocking"
echo "============================================================"
echo ""
echo "📋 Category: AKS"
echo "💰 Cost: bash.10"
echo "📋 Scenario: Azure Network Policy blocking pod-to-pod traffic"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.10" != "FREE" ] && echo "   Estimated cost: bash.10/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: Azure Network Policy blocking pod-to-pod traffic"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   kubectl get networkpolicies -A"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
