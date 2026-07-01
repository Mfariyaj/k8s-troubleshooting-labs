#!/bin/bash
# Lab 04: Artifact Passing Between Jobs - Deploy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-04-artifact-passing"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Setting up lab environment..."

# Create a temporary git repo
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/.github/workflows"

# Copy the broken workflow
cp "${SCRIPT_DIR}/.github/workflows/broken-artifacts.yml" "${WORK_DIR}/.github/workflows/broken-artifacts.yml"

# Initialize git repo
cd "${WORK_DIR}"
git init -q
git add .
git commit -q -m "Add artifact passing workflow"

echo "[${LAB_NAME}] Lab deployed to: ${WORK_DIR}"
echo ""

# Validate with actionlint if available
if command -v actionlint &> /dev/null; then
  echo "[${LAB_NAME}] Running actionlint validation:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  actionlint "${WORK_DIR}/.github/workflows/broken-artifacts.yml" 2>&1 || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "[${LAB_NAME}] Artifact issues detected:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Error: 'test' job downloads 'build-artifacts' but upload uses 'build-output'"
  echo "Error: 'test' job missing 'needs: [build]' — runs in parallel"
  echo "Warning: retention-days: 0 is invalid (minimum 1)"
  echo "Error: 'smoke-test' downloads 'test-results' which is never uploaded"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "[${LAB_NAME}] ✅ Lab ready! Fix the workflow at:"
echo "  ${WORK_DIR}/.github/workflows/broken-artifacts.yml"
echo ""
echo "  Check artifact names and job dependencies"
