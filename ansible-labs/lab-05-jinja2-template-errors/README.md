## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (sets up environment and runs broken playbook)
2. Read the Ansible error output carefully
3. Investigate: Check playbook.yml, inventory, roles, templates
4. Fix the broken configuration
5. Re-run: `ansible-playbook playbook.yml` to verify
6. Check `solution.md` if stuck

---

# Lab 05: Jinja2 Template Errors

## Difficulty: ⭐⭐ Medium

## Scenario
You're deploying a templated Nginx configuration. The template has multiple issues: it references `upstream_servers` which is undefined in vars, uses `max_worker_connections` instead of a defined variable, references `static_files_path` without definition, and has a missing `{% endfor %}` tag creating a syntax error.

## Expected Error Output
```
PLAY [Deploy Nginx with custom configuration] **********************************

TASK [Deploy nginx configuration template] *************************************
fatal: [web1]: FAILED! => {"changed": false, "msg": "AnsibleError: template error while templating string: 
Unexpected end of template. Jinja was looking for the following tags: 'endfor' or 'else'. 
The innermost block that needs to be closed is 'for'.
  Error was on template line 9"}

--- OR after fixing endfor ---

fatal: [web1]: FAILED! => {"changed": false, "msg": "AnsibleUndefinedVariable: 'upstream_servers' is undefined. 
'upstream_servers' is undefined"}
```

## Hints
1. Check the template for missing `{% endfor %}` — every `{% for %}` block must be closed.
2. Ensure all variables referenced in the template (`upstream_servers`, `max_worker_connections`, `static_files_path`) are defined in `vars`.
3. Use `ansible-playbook --syntax-check` first, then use `{{ variable | default('value') }}` for optional vars.

## Troubleshooting Commands
```bash
ansible-playbook playbook.yml --syntax-check
ansible-playbook playbook.yml --check -v
grep -n "{% " templates/nginx.conf.j2
grep -oP '\{\{ \w+' templates/nginx.conf.j2
ansible-playbook playbook.yml -e '{"upstream_servers": []}' --check
```
