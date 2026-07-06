#!/bin/bash
# =============================================================
# Lab 03: Variable Precedence Conflict
# =============================================================
# This lab demonstrates Ansible variable precedence issues:
#   - Variables defined in multiple places with conflicting values
#   - group_vars, host_vars, role defaults, role vars all conflict
#   - Extra vars and set_fact override unexpectedly
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 03: Variable Precedence Conflict" \
    "Variables from multiple sources conflict, causing wrong values in config"

echo "Running broken playbook..."
echo "---"
ansible-playbook -i inventory.ini playbook.yml 2>&1 || true
echo "---"

echo ""
echo "⚠️  The playbook may APPEAR to succeed, but deploys WRONG values!"
echo "   Check: What port did it configure? What environment? What paths?"
echo ""

print_lab_footer
