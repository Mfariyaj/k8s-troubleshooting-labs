#!/bin/bash
# Lab 15: Large State Performance - Deploy Script

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================"
echo "  Lab 15: Large State Performance Degradation"
echo "  Difficulty: EXPERT"
echo "  Estimated Time: 20-30 minutes"
echo "============================================================"
echo ""
echo "  Scenario: Terraform plan takes 45+ minutes. State file"
echo "  is 50MB+ with 2000+ resources. Redundant data sources,"
echo "  orphaned state entries, and no optimization flags."
echo "============================================================"
echo ""

cd "$LAB_DIR"

echo "[1/3] Initializing Terraform..."
terraform init -input=false 2>&1 || true

echo ""
echo "[2/3] Running state analysis..."
echo "---------------------------------------------------"
bash ./state-analysis.sh

echo ""
echo "[3/3] Lab deployed. Diagnose the performance issues!"
echo ""
echo "Files to investigate:"
echo "  - main.tf                        (root data sources)"
echo "  - modules/microservice/main.tf   (redundant data sources)"
echo "  - state-analysis.sh              (performance metrics)"
echo ""
echo "Start troubleshooting with:"
echo "  grep -r 'data \"aws_' . --include='*.tf' | wc -l"
echo "  terraform state list | wc -l"
echo ""
echo "Good luck! Fix the performance! 🔧"
