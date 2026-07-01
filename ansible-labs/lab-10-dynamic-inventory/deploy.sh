#!/bin/bash
echo "=== Lab 10: Dynamic Inventory Script Failure ==="
echo "Deploying broken Ansible playbook..."
echo ""
ansible-playbook -i inventory_script.py playbook.yml
