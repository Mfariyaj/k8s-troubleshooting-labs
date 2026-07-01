#!/bin/bash
echo "=== Lab 06: Vault Decryption Failure ==="
echo "Deploying broken Ansible playbook..."
echo ""
ansible-playbook -i inventory.ini playbook.yml --vault-password-file vault-password.txt
