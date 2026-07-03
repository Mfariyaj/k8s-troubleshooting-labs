#!/bin/bash
set -e
echo "🚀 Lab 20: aks pod identity failed"
echo "============================================================"
echo ""
echo "📋 Category: AKS"
echo "💰 Cost: bash.10"
echo "📋 Scenario: Azure AD Workload Identity not binding to pod"
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
echo "🔧 SCENARIO: Azure AD Workload Identity not binding to pod"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az aks show -n <aks> -g <rg> --query oidcIssuerProfile"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
