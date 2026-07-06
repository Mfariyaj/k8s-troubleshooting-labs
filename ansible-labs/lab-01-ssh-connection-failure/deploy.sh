#!/bin/bash
# =============================================================
# Lab 01: SSH Connection Failure
# =============================================================
# This lab has INTENTIONAL SSH problems you must fix:
#   - Wrong SSH key permissions (0644 instead of 0600)
#   - Wrong SSH port (2222 instead of correct port)
#   - StrictHostKeyChecking=yes blocking connections
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 01: SSH Connection Failure" \
    "Ansible fails to connect via SSH due to multiple misconfigurations"

echo "Creating broken SSH key with wrong permissions..."
# Create a fake key with wrong permissions (the bug!)
ssh-keygen -t rsa -b 2048 -f ./fake_key.pem -N "" -q 2>/dev/null || true
chmod 0644 fake_key.pem  # BUG: should be 0600

echo ""
echo "Running broken playbook..."
echo "---"
ansible-playbook -i inventory.ini playbook.yml 2>&1 || true
echo "---"

print_lab_footer
