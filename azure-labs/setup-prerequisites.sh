#!/bin/bash
echo "╔══════════════════════════════════════════════════════╗"
echo "║  Azure Labs - Prerequisites Setup                    ║"
echo "║  Run this ONCE before starting any Azure lab         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# Check Azure CLI
if ! command -v az &>/dev/null; then
  echo "❌ Azure CLI not installed!"
  echo ""
  echo "   Install:"
  echo "   Linux/WSL: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
  echo "   macOS:     brew install azure-cli"
  echo "   Windows:   winget install Microsoft.AzureCLI"
  echo ""
  exit 1
fi
echo "✅ Azure CLI: $(az version --query '\"azure-cli\"' -o tsv)"

# Check login
if ! az account show &>/dev/null 2>&1; then
  echo "❌ Not logged in to Azure!"
  echo "   Run: az login"
  exit 1
fi

SUB_NAME=$(az account show --query name -o tsv)
SUB_ID=$(az account show --query id -o tsv)
TENANT=$(az account show --query tenantId -o tsv)
USER=$(az account show --query user.name -o tsv)

echo "✅ Logged in!"
echo "   User: $USER"
echo "   Subscription: $SUB_NAME"
echo "   Subscription ID: $SUB_ID"
echo "   Tenant: $TENANT"
echo ""

# Check permissions
echo "🔍 Checking permissions..."
PERMS_OK=true

az group list --query '[0].name' -o tsv &>/dev/null || { echo "   ⚠️ Can't list resource groups"; PERMS_OK=false; }
az ad signed-in-user show &>/dev/null 2>&1 || { echo "   ⚠️ Can't read Azure AD (might be fine for some labs)"; }

if [ "$PERMS_OK" = true ]; then
  echo "✅ Permissions look good!"
else
  echo "⚠️ You may need Contributor or Owner role on the subscription."
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  ✅ Ready to start Azure labs!                       ║"
echo "║                                                      ║"
echo "║  Start with FREE labs (no charges):                  ║"
echo "║    cd lab-01-rbac-access-denied && ./deploy.sh       ║"
echo "║                                                      ║"
echo "║  ⚠️  Always cleanup after each lab:                   ║"
echo "║    ./cleanup.sh                                      ║"
echo "║                                                      ║"
echo "║  💰 Check COST-INFO in README.md before paid labs    ║"
echo "╚══════════════════════════════════════════════════════╝"
