#!/bin/bash
# Lab 06: Container Registry Push Failures - Deploy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-06-container-registry-push"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Setting up lab environment..."

# Create a temporary git repo
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/.github/workflows"

# Copy the broken workflow and Dockerfile
cp "${SCRIPT_DIR}/.github/workflows/broken-docker.yml" "${WORK_DIR}/.github/workflows/broken-docker.yml"
cp "${SCRIPT_DIR}/Dockerfile" "${WORK_DIR}/Dockerfile"

# Initialize git repo
cd "${WORK_DIR}"
git init -q
git add .
git commit -q -m "Add Docker build and push workflow"

echo "[${LAB_NAME}] Lab deployed to: ${WORK_DIR}"
echo ""

# Validate with actionlint if available
if command -v actionlint &> /dev/null; then
  echo "[${LAB_NAME}] Running actionlint validation:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  actionlint "${WORK_DIR}/.github/workflows/broken-docker.yml" 2>&1 || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "[${LAB_NAME}] Container registry issues detected:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Error: Login to 'gcr.io' — should be 'ghcr.io' for GitHub Container Registry"
  echo "Error: Image tag 'refs/heads/main' contains '/' — invalid Docker tag"
  echo "Error: Missing 'permissions: packages: write' for GHCR push"
  echo "Warning: GITHUB_TOKEN has insufficient permissions by default"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "[${LAB_NAME}] ✅ Lab ready! Fix the workflow at:"
echo "  ${WORK_DIR}/.github/workflows/broken-docker.yml"
echo ""
echo "  Check: registry URLs, image tags, and token permissions"
