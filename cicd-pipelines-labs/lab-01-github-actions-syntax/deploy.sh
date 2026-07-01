#!/bin/bash
# Lab 01: GitHub Actions Syntax Errors - Deploy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-01-github-actions-syntax"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Setting up lab environment..."

# Create a temporary git repo to simulate the scenario
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/.github/workflows"

# Copy the broken workflow
cp "${SCRIPT_DIR}/.github/workflows/broken-ci.yml" "${WORK_DIR}/.github/workflows/broken-ci.yml"

# Initialize git repo
cd "${WORK_DIR}"
git init -q
git add .
git commit -q -m "Add broken CI workflow"

echo "[${LAB_NAME}] Lab deployed to: ${WORK_DIR}"
echo ""

# Validate with actionlint if available
if command -v actionlint &> /dev/null; then
  echo "[${LAB_NAME}] Running actionlint validation:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  actionlint "${WORK_DIR}/.github/workflows/broken-ci.yml" 2>&1 || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "[${LAB_NAME}] actionlint not installed. Showing workflow errors manually:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Error: 'push_request' is not a valid event name"
  echo "Error: 'pull' is not a valid event name"
  echo "Error: 'steps' is not a valid job property at this indentation level"
  echo "Error: Must specify a version for action 'actions/checkout'"
  echo "Error: Must specify a version for action 'actions/setup-node'"
  echo "Error: Unexpected scalar value at line 18"
  echo "Error: Wrong indentation at line 29"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "[${LAB_NAME}] ✅ Lab ready! Fix the workflow at:"
echo "  ${WORK_DIR}/.github/workflows/broken-ci.yml"
echo ""
echo "  Diagnose with: actionlint ${WORK_DIR}/.github/workflows/broken-ci.yml"
