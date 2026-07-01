#!/bin/bash
# Lab 10: Deployment Gates & Rollback - Deploy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-10-deployment-gates"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Setting up lab environment..."

# Create a temporary git repo
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/.github/workflows"

# Copy the broken workflow
cp "${SCRIPT_DIR}/.github/workflows/broken-progressive.yml" "${WORK_DIR}/.github/workflows/broken-progressive.yml"

# Initialize git repo
cd "${WORK_DIR}"
git init -q
git add .
git commit -q -m "Add progressive deployment workflow"

echo "[${LAB_NAME}] Lab deployed to: ${WORK_DIR}"
echo ""

# Validate with actionlint if available
if command -v actionlint &> /dev/null; then
  echo "[${LAB_NAME}] Running actionlint validation:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  actionlint "${WORK_DIR}/.github/workflows/broken-progressive.yml" 2>&1 || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "[${LAB_NAME}] Progressive deployment issues:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Error: Health check hits localhost:8080 — should be canary URL"
  echo "Error: Rollback needs [deploy-full] but deploy-full is skipped when health fails"
  echo "Warning: Workflow-level cancel-in-progress: true cancels in-progress deploys"
  echo "Warning: deploy-canary and deploy-full share concurrency group"
  echo "Error: post-deploy-verification uses unresolvable internal URL"
  echo "Warning: notify-failure condition doesn't handle skipped jobs"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "[${LAB_NAME}] ✅ Lab ready! Fix the workflow at:"
echo "  ${WORK_DIR}/.github/workflows/broken-progressive.yml"
echo ""
echo "  Focus on: health check URLs, rollback conditions, and concurrency settings"
