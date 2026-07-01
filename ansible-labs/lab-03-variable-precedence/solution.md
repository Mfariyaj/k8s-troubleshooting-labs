## Solution: Variable Precedence Conflicts

### Root Cause

Variables defined at multiple levels with conflicting values. Ansible precedence
(highest to lowest):
1. Extra vars (`-e`)
2. Task/block vars
3. Role vars (`roles/x/vars/main.yml`)
4. Host vars (`host_vars/`)
5. Group vars (`group_vars/`)
6. Role defaults (`roles/x/defaults/main.yml`)

The lab defines the same variable in `role vars`, `group_vars`, and `defaults`,
causing the wrong value to be applied.

### Step-by-Step Fix

1. **Identify conflicting definitions:**
```bash
grep -r "http_port\|app_env" group_vars/ host_vars/ roles/
```

2. **Remove conflicting variables** from `roles/x/vars/main.yml` so that
   `group_vars` can properly override defaults:
```bash
# Clear roles/webapp/vars/main.yml or remove conflicting keys
```

3. **Use correct levels:**
   - Shared defaults -> `roles/x/defaults/main.yml`
   - Environment-specific -> `group_vars/`
   - Host-specific -> `host_vars/`

### Fixed Configuration

**group_vars/all.yml:**
```yaml
http_port: 8080
app_env: production
```

**roles/webapp/defaults/main.yml:**
```yaml
http_port: 80
app_env: development
max_connections: 100
```

Remove or empty `roles/webapp/vars/main.yml` so group_vars can override defaults.

### Verification

```bash
# Check effective variable value
ansible all -m debug -a "var=http_port"

# Run with verbosity to see variable sources
ansible-playbook playbook.yml -v

# Override with extra vars to confirm precedence
ansible-playbook playbook.yml -e "http_port=9090" -v
```

### Key Takeaway

Use `defaults/` for values meant to be overridden. Use `vars/` only for
role-internal constants. Never put the same variable in both unless you
understand which wins.
