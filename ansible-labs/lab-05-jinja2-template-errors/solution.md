## Solution: Jinja2 Template Errors

### Root Cause

The Jinja2 templates contain three types of errors:
1. **Undefined variables** — referencing variables never defined in vars
2. **Missing `{% endfor %}`** — a for loop block is never closed
3. **Broken filter syntax** — e.g., `| defaults` instead of `| default`

### Step-by-Step Fix

1. **Define all required variables in vars/main.yml:**
```yaml
app_name: myapp
server_port: 8080
allowed_hosts:
  - 192.168.1.0/24
  - 10.0.0.0/8
db_host: localhost
```

2. **Add missing `{% endfor %}`:**
```jinja2
{% for host in allowed_hosts %}
allow {{ host }};
{% endfor %}
```

3. **Fix filter syntax:**
```jinja2
# Wrong:
{{ variable | defaults('fallback') }}
# Correct:
{{ variable | default('fallback') }}
```

### Fixed Configuration

**templates/app.conf.j2:**
```jinja2
server {
    listen {{ server_port | default(8080) }};
    server_name {{ app_name }};

    {% for host in allowed_hosts %}
    allow {{ host }};
    {% endfor %}
    deny all;

    location / {
        proxy_pass http://{{ db_host | default('localhost') }}:5432;
    }
}
```

**vars/main.yml:**
```yaml
app_name: myapp
server_port: 8080
allowed_hosts:
  - 192.168.1.0/24
  - 10.0.0.0/8
db_host: localhost
```

### Verification

```bash
# Validate template syntax
ansible-playbook playbook.yml --syntax-check

# Check mode to see rendered output
ansible-playbook playbook.yml --check --diff -v

# Full run
ansible-playbook playbook.yml -v
```

### Key Takeaway

Always close Jinja2 blocks (`{% endfor %}`, `{% endif %}`). Use `| default()`
not `| defaults()`. Define all variables or use `default()` filters as fallback.
