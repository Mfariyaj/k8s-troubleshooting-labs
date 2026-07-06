#!/bin/bash
# =============================================================
# Lab 05: Jinja2 Template Errors
# =============================================================
# This lab has INTENTIONAL template problems:
#   - Undefined variables in templates
#   - Wrong filter usage (| vs ())
#   - Missing loop closing tags
#   - Incorrect conditional syntax
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 05: Jinja2 Template Errors" \
    "Ansible template module fails due to Jinja2 syntax errors"

echo "Running broken playbook..."
echo "---"
ansible-playbook -i inventory.ini playbook.yml 2>&1 || true
echo "---"

print_lab_footer
