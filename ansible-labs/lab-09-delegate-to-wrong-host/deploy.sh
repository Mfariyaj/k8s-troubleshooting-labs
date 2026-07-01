#!/bin/bash
echo "=== Lab 09: Delegate To Wrong Host ==="
echo "Deploying broken Ansible playbook..."
echo ""
ansible-playbook -i inventory.ini playbook.yml
