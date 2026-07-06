#!/bin/bash
# =============================================================
# Lab 09: Delegate To Wrong Host
# =============================================================
# This lab has INTENTIONAL delegation problems:
#   - delegate_to pointing to non-existent host
#   - Facts gathered from wrong host due to delegation
#   - delegate_facts not set correctly
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 09: Delegate To Wrong Host" \
    "Tasks execute on wrong hosts due to incorrect delegate_to usage"

echo "Running broken playbook..."
echo "---"
ansible-playbook -i inventory.ini playbook.yml 2>&1 || true
echo "---"

echo ""
echo "⚠️  Tasks ran on the WRONG host! Check delegate_to configuration."
echo ""

print_lab_footer
