#!/bin/bash
# Lab 11: Cross-Account Assume Role - Deploy Script
# This lab focuses on troubleshooting cross-account IAM role assumption

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-11-cross-account-assume-role"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Lab 11: Cross-Account Assume Role Failure                  ║"
echo "║  Difficulty: EXPERT                                         ║"
echo "║  Estimated Time: 20-30 minutes                              ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Scenario: Terraform fails to assume a cross-account IAM    ║"
echo "║  role. Multiple issues in trust policy, external ID,        ║"
echo "║  session duration, and permission boundaries.               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$LAB_DIR"

echo "[1/3] Initializing Terraform..."
terraform init -input=false 2>&1 || true

echo ""
echo "[2/3] Running terraform plan (expect failures)..."
echo "---------------------------------------------------"
terraform plan 2>&1 || true

echo ""
echo "---------------------------------------------------"
echo "[3/3] Lab deployed. Diagnose and fix the issues!"
echo ""
echo "Files to investigate:"
echo "  - providers.tf  (provider assume_role configuration)"
echo "  - iam.tf        (trust policy, permission boundary)"
echo "  - main.tf       (resources being created)"
echo ""
echo "Start troubleshooting with:"
echo "  terraform validate"
echo "  TF_LOG=DEBUG terraform plan 2>&1 | head -100"
echo ""
echo "Good luck! 🔧"
