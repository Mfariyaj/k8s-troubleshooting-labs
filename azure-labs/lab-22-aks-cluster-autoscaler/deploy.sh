#!/bin/bash
set -e
echo "🚀 Lab 22: aks cluster autoscaler"
echo "============================================================"
echo ""
echo "📋 Category: AKS"
echo "💰 Cost: bash.10"
echo "📋 Scenario: Cluster autoscaler not scaling: VMSS quota hit"
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
echo "🔧 SCENARIO: Cluster autoscaler not scaling: VMSS quota hit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🛠️ Debug command:"
echo "   az aks nodepool show --cluster-name <aks> -n <pool> -g <rg>"
echo ""
echo "📖 Follow guide.md for:"
echo "   - Azure Portal (GUI) step-by-step"
echo "   - Azure CLI commands"
echo "   - PowerShell alternative"
echo ""
echo "🧹 When done: ./cleanup.sh"
