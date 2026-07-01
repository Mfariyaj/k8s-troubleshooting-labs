#!/bin/bash
# Lab 05: Environment Protection Rules - Deploy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-05-environment-protection"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Setting up lab environment..."

# Create a temporary git repo
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/.github/workflows"

# Copy the broken workflow
cp "${SCRIPT_DIR}/.github/workflows/broken-deploy.yml" "${WORK_DIR}/.github/workflows/broken-deploy.yml"

# Initialize git repo
cd "${WORK_DIR}"
git init -q
git add .
git commit -q -m "Add production deployment workflow"

echo "[${LAB_NAME}] Lab deployed to: ${WORK_DIR}"
echo ""

# Validate with actionlint if available
if command -v actionlint &> /dev/null; then
  echo "[${LAB_NAME}] Running actionlint validation:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  actionlint "${WORK_DIR}/.github/workflows/broken-deploy.yml" 2>&1 || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "[${LAB_NAME}] Environment protection issues detected:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Error: wait-timer: -1 is invalid (valid: 0-43200)"
  echo "Warning: deploy-production skips staging (needs: [build] not [deploy-staging])"
  echo "Warning: cancel-in-progress: true is dangerous for production"
  echo "Warning: Rollback has 30-minute wait-timer (should be immediate)"
  echo "Warning: No branch protection configured for production environment"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "[${LAB_NAME}] ✅ Lab ready! Fix the workflow at:"
echo "  ${WORK_DIR}/.github/workflows/broken-deploy.yml"
echo ""
echo "  Review environment protection and deployment ordering"
