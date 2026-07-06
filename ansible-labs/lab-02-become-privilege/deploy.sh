#!/bin/bash
# =============================================================
# Lab 02: Become Privilege Escalation Failure
# =============================================================
# This lab has INTENTIONAL privilege escalation problems:
#   - Wrong become method configured
#   - User doesn't have proper sudo access
#   - become_user conflicts with task requirements
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 02: Become Privilege Escalation Failure" \
    "Ansible tasks fail when trying to escalate privileges with sudo/become"

echo "Running broken playbook..."
echo "---"
ansible-playbook -i inventory.ini playbook.yml 2>&1 || true
echo "---"

print_lab_footer
