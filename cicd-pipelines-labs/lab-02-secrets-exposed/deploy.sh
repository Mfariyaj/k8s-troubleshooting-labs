#!/bin/bash
# Lab 02: Secrets Exposed in Logs - Deploy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-02-secrets-exposed"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Setting up lab environment..."

# Create a temporary git repo
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/.github/workflows"

# Copy the broken workflow
cp "${SCRIPT_DIR}/.github/workflows/broken-build.yml" "${WORK_DIR}/.github/workflows/broken-build.yml"

# Initialize git repo
cd "${WORK_DIR}"
git init -q
git add .
git commit -q -m "Add build workflow with secrets"

echo "[${LAB_NAME}] Lab deployed to: ${WORK_DIR}"
echo ""

# Validate with actionlint if available
if command -v actionlint &> /dev/null; then
  echo "[${LAB_NAME}] Running actionlint validation:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  actionlint "${WORK_DIR}/.github/workflows/broken-build.yml" 2>&1 || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "[${LAB_NAME}] Security issues detected in workflow:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "WARNING: Secret directly echoed in 'Debug environment' step"
  echo "WARNING: Environment variable dump exposes secrets"
  echo "WARNING: Secret used in if: condition (leaks in debug mode)"
  echo "WARNING: Secret value embedded in notification message"
  echo "WARNING: Webhook URL exposed in curl command"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "[${LAB_NAME}] ✅ Lab ready! Review the workflow for secret exposure:"
echo "  ${WORK_DIR}/.github/workflows/broken-build.yml"
echo ""
echo "  Find secrets leaks: grep -n 'secrets\\|echo\\|env |' ${WORK_DIR}/.github/workflows/broken-build.yml"
