#!/bin/bash
# =============================================================
# Lab 07: Role Circular Dependencies
# =============================================================
# This lab has INTENTIONAL role dependency issues:
#   - Circular dependency between roles
#   - Wrong meta/main.yml dependencies
#   - Role not found in correct path
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 07: Role Circular Dependencies" \
    "Ansible hangs or errors due to circular role dependencies"

echo "Running broken playbook..."
echo "---"
ansible-playbook -i localhost, site.yml 2>&1 || true
echo "---"

print_lab_footer
