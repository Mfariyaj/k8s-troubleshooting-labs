#!/bin/bash
# Lab 08: CI Cache Misses - Deploy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-08-ci-cache-miss"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Setting up lab environment..."

# Create a temporary git repo
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/.github/workflows"

# Copy the broken workflows
cp "${SCRIPT_DIR}/.github/workflows/broken-cache.yml" "${WORK_DIR}/.github/workflows/broken-cache.yml"
cp "${SCRIPT_DIR}/.gitlab-ci.yml" "${WORK_DIR}/.gitlab-ci.yml"

# Create a package-lock.json to simulate npm project (NOT yarn.lock)
cat > "${WORK_DIR}/package-lock.json" << 'EOF'
{
  "name": "broken-cache-lab",
  "version": "1.0.0",
  "lockfileVersion": 3
}
EOF

cat > "${WORK_DIR}/package.json" << 'EOF'
{
  "name": "broken-cache-lab",
  "version": "1.0.0",
  "scripts": {
    "build": "echo build",
    "test": "echo test",
    "lint": "echo lint"
  }
}
EOF

# Initialize git repo
cd "${WORK_DIR}"
git init -q
git add .
git commit -q -m "Add CI workflows with caching"

echo "[${LAB_NAME}] Lab deployed to: ${WORK_DIR}"
echo ""

# Validate with actionlint if available
if command -v actionlint &> /dev/null; then
  echo "[${LAB_NAME}] Running actionlint validation:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  actionlint "${WORK_DIR}/.github/workflows/broken-cache.yml" 2>&1 || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "[${LAB_NAME}] Cache configuration issues:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Error: hashFiles('**/yarn.lock') — project uses package-lock.json, not yarn.lock"
  echo "Warning: Caching node_modules/ but using 'npm ci' (deletes node_modules)"
  echo "Warning: restore-keys too specific — include hashFiles defeating fallback purpose"
  echo "Error: GitLab cache key includes CI_RUNNER_ID — unique per runner, never hits"
  echo "Warning: GitLab lint job policy: pull only — cache never updated"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "[${LAB_NAME}] ✅ Lab ready! Fix the workflows at:"
echo "  ${WORK_DIR}/.github/workflows/broken-cache.yml"
echo "  ${WORK_DIR}/.gitlab-ci.yml"
echo ""
echo "  Note: Project uses npm (package-lock.json exists, yarn.lock does NOT)"
