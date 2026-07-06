#!/bin/bash
# =============================================================
# Lab 10: Dynamic Inventory Script Failure
# =============================================================
# This lab has INTENTIONAL dynamic inventory problems:
#   - Python script has syntax errors
#   - Script not executable
#   - JSON output format incorrect
#   - Missing --list / --host arguments handling
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 10: Dynamic Inventory Script Failure" \
    "Custom dynamic inventory script fails to produce valid JSON"

echo "Testing inventory script directly..."
echo "---"
python3 inventory_script.py --list 2>&1 || true
echo "---"
echo ""
echo "Running playbook with dynamic inventory..."
echo "---"
ansible-playbook -i inventory_script.py playbook.yml 2>&1 || true
echo "---"

echo ""
echo "⚠️  Dynamic inventory script fails! Check the Python script."
echo ""

print_lab_footer
