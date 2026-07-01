#!/bin/bash
# Lab 07: GitLab CI Stages & Dependencies - Deploy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-07-gitlab-ci-stages"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Setting up lab environment..."

# Create a temporary git repo
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

# Copy the broken GitLab CI file
cp "${SCRIPT_DIR}/.gitlab-ci.yml" "${WORK_DIR}/.gitlab-ci.yml"

# Initialize git repo
cd "${WORK_DIR}"
git init -q
git add .
git commit -q -m "Add GitLab CI configuration"

echo "[${LAB_NAME}] Lab deployed to: ${WORK_DIR}"
echo ""

# Validate with yamllint if available
if command -v yamllint &> /dev/null; then
  echo "[${LAB_NAME}] Running yamllint validation:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  yamllint "${WORK_DIR}/.gitlab-ci.yml" 2>&1 || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "[${LAB_NAME}] GitLab CI pipeline issues:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Error: 'unit_tests' needs 'build_application' — job does not exist"
echo "Error: Stages order (deploy→test→build) conflicts with job dependencies"
echo "Error: 'lint' job has conflicting rules for same condition"
echo "Warning: 'deploy_production' needs 'deploy_staging' but both are in 'deploy' stage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "[${LAB_NAME}] ✅ Lab ready! Fix the GitLab CI at:"
echo "  ${WORK_DIR}/.gitlab-ci.yml"
echo ""
echo "  Validate: Check stages order, job names in needs, and rule conflicts"
