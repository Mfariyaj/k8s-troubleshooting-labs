# Lab 09: Delegate To Wrong Host

## Difficulty: ⭐⭐⭐ Hard

## Scenario
You're deploying a web app and registering servers with a load balancer using `delegate_to`. The playbook uses `{{ lb_server }}` and `{{ monitoring_host }}` in `delegate_to` directives, but these variables are never defined. Ansible fails with an undefined variable error when trying to resolve the delegation target.

## Expected Error Output
```
PLAY [Deploy and register service with load balancer] **************************

TASK [Install nginx on web server] *********************************************
ok: [web1]

TASK [Deploy application] ******************************************************
changed: [web1]

TASK [Register this server with the load balancer] *****************************
fatal: [web1]: FAILED! => {"msg": "The task includes an option with an undefined variable. 
The error was: 'lb_server' is undefined. 
'lb_server' is undefined

The error appears to be in 'playbook.yml': line 15, column 7"}
```

## Hints
1. The variables `lb_server` and `monitoring_host` used in `delegate_to` are never defined anywhere.
2. Either define these variables in inventory, group_vars, or use the actual host name from inventory (e.g., `lb1`).
3. `delegate_to` needs an actual hostname or IP — not an undefined variable reference.

## Troubleshooting Commands
```bash
ansible-playbook playbook.yml --syntax-check
ansible-inventory -i inventory.ini --list
grep -n "delegate_to\|lb_server\|monitoring_host" playbook.yml
ansible-playbook playbook.yml -e "lb_server=lb1 monitoring_host=mon1" --check
ansible all -i inventory.ini --list-hosts
```
