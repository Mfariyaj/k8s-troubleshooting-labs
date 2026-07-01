#!/bin/bash
echo "=== Lab 03: Variable Precedence Conflict ==="
echo "Deploying broken Ansible playbook..."
echo ""
ansible-playbook -i inventory.ini playbook.yml
