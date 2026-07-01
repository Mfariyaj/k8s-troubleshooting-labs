## Solution: Dynamic Inventory Script Broken

### Root Cause

Three issues with the dynamic inventory script:
1. **Not executable** — script lacks execute permission
2. **Wrong JSON format** — outputs a list instead of the required dictionary
3. **Missing `_meta`** — no `_meta.hostvars` section, causing failures

### Step-by-Step Fix

1. **Make the script executable:**
```bash
chmod +x inventory_script.py
```

2. **Fix JSON output to use dict format (not list):**
```python
# Wrong: ["host1", "host2"]
# Correct:
{
    "webservers": {
        "hosts": ["web1", "web2"],
        "vars": {"http_port": 80}
    }
}
```

3. **Add proper `_meta` section:**
```python
"_meta": {
    "hostvars": {
        "web1": {"ansible_host": "192.168.1.10"},
        "web2": {"ansible_host": "192.168.1.11"}
    }
}
```

### Fixed Configuration

**inventory_script.py:**
```python
#!/usr/bin/env python3
import json, sys

def get_inventory():
    return {
        "webservers": {
            "hosts": ["web1", "web2"],
            "vars": {"http_port": 80}
        },
        "_meta": {
            "hostvars": {
                "web1": {"ansible_host": "192.168.1.10"},
                "web2": {"ansible_host": "192.168.1.11"}
            }
        }
    }

def get_host(host):
    inventory = get_inventory()
    return inventory["_meta"]["hostvars"].get(host, {})

if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        print(json.dumps(get_inventory(), indent=2))
    elif len(sys.argv) == 3 and sys.argv[1] == "--host":
        print(json.dumps(get_host(sys.argv[2]), indent=2))
    else:
        print(json.dumps({}))
```

### Verification

```bash
chmod +x inventory_script.py
./inventory_script.py --list | python3 -m json.tool
ansible-inventory -i inventory_script.py --list
ansible-playbook -i inventory_script.py playbook.yml -v
```

### Key Takeaway

Dynamic inventory scripts must be executable, respond to `--list` with a JSON
dict (not a list), and include `_meta.hostvars` to avoid per-host callbacks.
