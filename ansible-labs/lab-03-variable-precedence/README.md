# Lab 03: Variable Precedence Conflict

## Difficulty: ⭐⭐ Medium

## Scenario
You expect the application to deploy on port 9090 (defined in `host_vars/web1.yml`) but it always deploys on port 443. The variable `http_port` is defined in 5 different places: `roles/app/vars/main.yml`, `roles/app/defaults/main.yml`, `group_vars/all.yml`, `group_vars/webservers.yml`, and `host_vars/web1.yml`. The role's `vars/main.yml` overrides everything unexpectedly.

## Expected Error Output
```
PLAY [Deploy web application with correct settings] ****************************

TASK [Display the configured HTTP port] ****************************************
ok: [web1] => {
    "msg": "Application will run on port 443"
}

TASK [Display the environment] *************************************************
ok: [web1] => {
    "msg": "Deploying to environment: production-locked"
}

TASK [Display max connections] *************************************************
ok: [web1] => {
    "msg": "Max connections: 500"
}
```

## Hints
1. Review the Ansible variable precedence order — which source has the highest priority?
2. `roles/vars/main.yml` has higher precedence than `host_vars` — is that what you want?
3. Move variables from `roles/app/vars/main.yml` to `roles/app/defaults/main.yml` if you want them overridable.

## Troubleshooting Commands
```bash
ansible-inventory -i inventory.ini --host web1
ansible-playbook playbook.yml --extra-vars "http_port=9090" -i inventory.ini --check
cat roles/app/vars/main.yml
cat host_vars/web1.yml
ansible-config dump | grep DEFAULT_HASH_BEHAVIOUR
```
