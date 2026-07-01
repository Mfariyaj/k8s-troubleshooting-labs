#!/bin/bash
echo "=== Lab 02: Become Privilege Escalation Failure ==="
echo "Deploying broken Ansible playbook..."
echo ""
ansible-playbook -i inventory.ini playbook.yml
