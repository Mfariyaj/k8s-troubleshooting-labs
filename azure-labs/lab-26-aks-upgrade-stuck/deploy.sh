#!/bin/bash
set -e
echo "🚀 Lab 26: aks upgrade stuck"
echo "============================================================"
echo ""
echo "📋 Category: AKS"
echo "💰 Cost: bash.10"
echo "📋 Scenario: AKS upgrade stuck: PDB blocking drain, surge maxUnavailable"
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
echo "🔧 SCENARIO: AKS upgrade stuck: PDB blocking drain, surge maxUnavailable"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az aks show -n <aks> -g <rg> --query currentKubernetesVersion"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
