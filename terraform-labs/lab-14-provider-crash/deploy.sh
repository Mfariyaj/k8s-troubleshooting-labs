#!/bin/bash
# Lab 14: Provider Crash / Panic - Deploy Script

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-14-provider-crash"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Lab 14: Provider Crash / Panic During Plan                 ║"
echo "║  Difficulty: EXPERT                                         ║"
echo "║  Estimated Time: 15-25 minutes                              ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Scenario: Community provider panics during terraform plan.  ║"
echo "║  Stack trace shows nil pointer dereference. Provider binary  ║"
echo "║  is incompatible with Terraform version.                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$LAB_DIR"

echo "[1/3] Checking Terraform version..."
terraform version 2>&1 || echo "Terraform not found - install terraform >= 1.5.0"

echo ""
echo "[2/3] Attempting terraform init (expect warnings/errors)..."
echo "---------------------------------------------------"
terraform init -input=false 2>&1 || true

echo ""
echo "[3/3] Attempting terraform plan (expect crash/panic)..."
echo "---------------------------------------------------"
TF_LOG=ERROR terraform plan 2>&1 || true

echo ""
echo "---------------------------------------------------"
echo "Lab deployed. Diagnose the provider crash!"
echo ""
echo "Files to investigate:"
echo "  - versions.tf  (provider version constraints & sources)"
echo "  - main.tf      (provider configuration blocks & resources)"
echo ""
echo "Key diagnostics:"
echo "  terraform version"
echo "  TF_LOG=DEBUG terraform plan 2>&1 | tail -50"
echo "  cat crash.log  (if generated)"
echo ""
echo "Look for:"
echo "  - Protocol version mismatches"
echo "  - Nil pointer dereferences"
echo "  - Version constraint excluding fix versions"
echo ""
echo "Good luck! 🔧"
