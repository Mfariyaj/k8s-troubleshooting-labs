# Lab 01: SSH Connection Failure

## Difficulty: ⭐ Easy

## Scenario
You're deploying an Nginx web server to remote hosts using Ansible. The playbook fails immediately with SSH connection errors. The inventory uses port 2222, user 'deployer', and a private key file with incorrect permissions (0644 instead of 0600). Additionally, `host_key_checking` is set to `True` with `StrictHostKeyChecking=yes`.

## Expected Error Output
```
PLAY [Deploy application to web servers] ***************************************

TASK [Gathering Facts] *********************************************************
fatal: [web1]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: 
Warning: Permanently added '192.168.1.100' (ECDSA) to the list of known hosts.\r\n
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\r\n
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @\r\n
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\r\n
Permissions 0644 for './fake_key.pem' are too open.\r\n
It is required that your private key files are NOT accessible by others.\r\n
This private key will be ignored.\r\nPermission denied (publickey).", "unreachable": true}

PLAY RECAP *********************************************************************
web1 : ok=0    changed=0    unreachable=1    failed=0    skipped=0
```

## Hints
1. Check the file permissions on the SSH private key — what does SSH require?
2. Is port 2222 the correct SSH port for your target hosts? Default SSH port is 22.
3. Look at `ansible.cfg` — is `host_key_checking` causing first-connection failures?

## Troubleshooting Commands
```bash
ls -la fake_key.pem
ansible all -i inventory.ini -m ping -vvv
ssh -i fake_key.pem -p 2222 deployer@192.168.1.100 -v
ansible-config dump | grep -i host_key
cat ansible.cfg
```
