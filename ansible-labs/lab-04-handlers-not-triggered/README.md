## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (sets up environment and runs broken playbook)
2. Read the Ansible error output carefully
3. Investigate: Check playbook.yml, inventory, roles, templates
4. Fix the broken configuration
5. Re-run: `ansible-playbook playbook.yml` to verify
6. Check `solution.md` if stuck

---

# Lab 04: Handlers Not Triggered

## Difficulty: ⭐ Easy

## Scenario
You deploy an Nginx configuration that changes the config file. The playbook reports "changed" on the template task, but the handler to restart Nginx never runs. The service continues serving the old configuration. The `notify` directive says `"Restart Nginx"` but the handler is named `"restart nginx"` (case mismatch).

## Expected Error Output
```
PLAY [Configure Nginx web server] **********************************************

TASK [Install nginx] ***********************************************************
ok: [web1]

TASK [Deploy nginx configuration] **********************************************
changed: [web1]

TASK [Deploy site configuration] ***********************************************
changed: [web1]

TASK [Ensure nginx is started] *************************************************
ok: [web1]

PLAY RECAP *********************************************************************
web1 : ok=4    changed=2    unreachable=0    failed=0    skipped=0

# NOTE: Handler "restart nginx" never executed despite config changes!
```

## Hints
1. Handler names are case-sensitive — compare `notify` value to handler `name` exactly.
2. Look for capitalization differences: `"Restart Nginx"` vs `"restart nginx"`.
3. Handlers only fire when notified by the exact matching name string.

## Troubleshooting Commands
```bash
ansible-playbook playbook.yml --syntax-check
grep -n "notify" playbook.yml
grep -n "name:" playbook.yml | grep -i handler
ansible-playbook playbook.yml --list-handlers
ansible-playbook playbook.yml -v --check
```
