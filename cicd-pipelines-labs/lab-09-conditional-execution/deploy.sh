#!/bin/bash
# Lab 09: Conditional Execution Logic - Deploy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-09-conditional-execution"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Setting up lab environment..."

# Create a temporary git repo
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/.github/workflows"
mkdir -p "${WORK_DIR}/src/api"
mkdir -p "${WORK_DIR}/src/components"
mkdir -p "${WORK_DIR}/docs"

# Copy the broken workflows
cp "${SCRIPT_DIR}/.github/workflows/broken-conditions.yml" "${WORK_DIR}/.github/workflows/broken-conditions.yml"
cp "${SCRIPT_DIR}/.gitlab-ci.yml" "${WORK_DIR}/.gitlab-ci.yml"

# Create sample source files
echo "export const server = {};" > "${WORK_DIR}/src/api/server.ts"
echo "export const App = () => {};" > "${WORK_DIR}/src/components/App.tsx"
echo "# Documentation" > "${WORK_DIR}/docs/README.md"

# Initialize git repo
cd "${WORK_DIR}"
git init -q
git add .
git commit -q -m "Initial commit with source code"

# Make a source code change to simulate the trigger issue
echo "// updated" >> "${WORK_DIR}/src/api/server.ts"
git add .
git commit -q -m "Update backend source code"

echo "[${LAB_NAME}] Lab deployed to: ${WORK_DIR}"
echo ""

# Validate with actionlint if available
if command -v actionlint &> /dev/null; then
  echo "[${LAB_NAME}] Running actionlint validation:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  actionlint "${WORK_DIR}/.github/workflows/broken-conditions.yml" 2>&1 || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "[${LAB_NAME}] Conditional execution issues:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Error: Workflow paths filter only matches 'docs/**' — source changes won't trigger"
  echo "Error: Output name 'backend_changed' doesn't match actual output 'backend'"
  echo "Error: String vs boolean comparison: '== true' should be '== '\"'\"'true'\"'\"''"
  echo "Warning: 'always()' on deploy job — runs even when builds are skipped"
  echo "Error: GitLab 'build-backend' — 'when: never' for main matches before changes rule"
  echo "Warning: GitLab 'deploy-canary' has catch-all 'when: always'"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "[${LAB_NAME}] ✅ Lab ready! Fix the workflows at:"
echo "  ${WORK_DIR}/.github/workflows/broken-conditions.yml"
echo "  ${WORK_DIR}/.gitlab-ci.yml"
echo ""
echo "  Last commit modified: src/api/server.ts (source code, not docs)"
