#!/bin/bash
echo "=== Lab 04: Handlers Not Triggered ==="
echo "Deploying broken Ansible playbook..."
echo ""
ansible-playbook -i inventory.ini playbook.yml
