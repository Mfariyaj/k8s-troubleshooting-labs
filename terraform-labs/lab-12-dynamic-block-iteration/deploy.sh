#!/bin/bash
# Lab 12: Dynamic Block Iteration - Deploy Script

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-12-dynamic-block-iteration"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Lab 12: Dynamic Block Iteration Failures                   ║"
echo "║  Difficulty: EXPERT                                         ║"
echo "║  Estimated Time: 15-25 minutes                              ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Scenario: Complex dynamic blocks with nested for_each      ║"
echo "║  produce wrong infrastructure. Security group rules don't   ║"
echo "║  match expected count or values.                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$LAB_DIR"

echo "[1/3] Initializing Terraform..."
terraform init -input=false 2>&1 || true

echo ""
echo "[2/3] Running terraform plan (expect errors or wrong output)..."
echo "---------------------------------------------------"
terraform plan 2>&1 || true

echo ""
echo "---------------------------------------------------"
echo "[3/3] Lab deployed. Diagnose and fix the dynamic blocks!"
echo ""
echo "Files to investigate:"
echo "  - main.tf           (dynamic blocks with nested iteration)"
echo "  - variables.tf      (variable type definitions)"
echo "  - terraform.tfvars  (complex input data)"
echo ""
echo "Start troubleshooting with:"
echo "  terraform console"
echo "  > local.flattened_rules"
echo "  > length(local.flattened_rules)"
echo ""
echo "Expected: 12 ingress rules, 3 egress rules"
echo "Good luck! 🔧"
