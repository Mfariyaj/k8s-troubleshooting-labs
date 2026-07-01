#!/bin/bash
# Clean up all CI/CD Pipeline troubleshooting labs
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  CI/CD Pipelines Labs - Cleanup All"
echo "=========================================="
echo ""

LABS=(
  "lab-01-github-actions-syntax"
  "lab-02-secrets-exposed"
  "lab-03-matrix-strategy"
  "lab-04-artifact-passing"
  "lab-05-environment-protection"
  "lab-06-container-registry-push"
  "lab-07-gitlab-ci-stages"
  "lab-08-ci-cache-miss"
  "lab-09-conditional-execution"
  "lab-10-deployment-gates"
)

for lab in "${LABS[@]}"; do
  echo "  Cleaning: ${lab}"
  if [ -f "${SCRIPT_DIR}/${lab}/cleanup.sh" ]; then
    bash "${SCRIPT_DIR}/${lab}/cleanup.sh"
  else
    echo "  [WARN] No cleanup.sh found for ${lab}"
  fi
done

echo ""
echo "=========================================="
echo "  All CI/CD labs cleaned up!"
echo "=========================================="
