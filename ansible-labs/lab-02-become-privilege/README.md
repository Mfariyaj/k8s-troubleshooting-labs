# Lab 02: Become Privilege Escalation Failure

## Difficulty: ⭐ Easy

## Scenario
You're installing packages on remote servers using Ansible. The playbook uses `apt` to install nginx and dependencies but fails with permission denied errors. The `become` directive is not set in the playbook, `ansible.cfg` sets `become=False` with `become_method=su`, and `become_ask_pass=True` blocks non-interactive execution.

## Expected Error Output
```
PLAY [Install and configure web application] ***********************************

TASK [Gathering Facts] *********************************************************
ok: [web1]

TASK [Update apt cache] ********************************************************
fatal: [web1]: FAILED! => {"changed": false, "msg": "Failed to lock apt for exclusive operation: E: Could not open lock file /var/lib/apt/lists/lock - open (13: Permission denied)"}

PLAY RECAP *********************************************************************
web1 : ok=1    changed=0    unreachable=0    failed=1    skipped=0
```

## Hints
1. Which tasks require root privileges? Does `apt` need elevated permissions?
2. Check `ansible.cfg` — is `become` enabled? What `become_method` is configured?
3. Can `become_ask_pass=True` work in a non-interactive script? What's the alternative?

## Troubleshooting Commands
```bash
ansible-config dump | grep -i become
ansible all -i inventory.ini -m shell -a "whoami"
ansible all -i inventory.ini -m shell -a "whoami" --become
cat ansible.cfg
ansible-playbook playbook.yml --syntax-check
```
