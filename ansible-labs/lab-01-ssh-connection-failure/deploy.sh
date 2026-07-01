#!/bin/bash
echo "=== Lab 01: SSH Connection Failure ==="
echo "Deploying broken Ansible playbook..."
echo ""
ansible-playbook -i inventory.ini playbook.yml
