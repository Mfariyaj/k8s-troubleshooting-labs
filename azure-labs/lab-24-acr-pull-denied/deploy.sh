#!/bin/bash
set -e
echo "🚀 Lab 24: acr pull denied"
echo "============================================================"
echo ""
echo "📋 Category: AKS"
echo "💰 Cost: bash.02"
echo "📋 Scenario: AKS can't pull from ACR: kubelet identity missing AcrPull role"
echo ""
echo "⚠️  This will create Azure resources in your subscription!"
[ "bash.02" != "FREE" ] && echo "   Estimated cost: bash.02/hour — run cleanup.sh when done!"
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
echo "🔧 SCENARIO: AKS can't pull from ACR: kubelet identity missing AcrPull role"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az aks check-acr -n <aks> -g <rg> --acr <acr>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
