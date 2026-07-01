## Solution: Custom Module Broken

### Root Cause

The custom Ansible module has multiple issues:
1. **Uses `print()`** — modules must not print to stdout; use module.exit_json()
2. **Missing `changed` key** — return dict must include `changed: true/false`
3. **Wrong `argument_spec` types** — type definitions don't match expected format
4. **Missing `supports_check_mode=True`** — module fails when run with `--check`

### Step-by-Step Fix

1. **Remove all `print()` statements:**
```python
# Wrong:
print("Task completed")
# Correct:
module.exit_json(changed=True, msg="Task completed")
```

2. **Always include `changed` in exit_json:**
```python
module.exit_json(changed=True, msg="Resource created")
module.exit_json(changed=False, msg="Already exists")
```

3. **Fix argument_spec types:**
```python
argument_spec = dict(
    name=dict(type='str', required=True),
    state=dict(type='str', default='present', choices=['present', 'absent']),
    count=dict(type='int', default=1),
)
```

4. **Add supports_check_mode:**
```python
module = AnsibleModule(
    argument_spec=argument_spec,
    supports_check_mode=True
)
```

### Fixed Configuration

**library/custom_module.py:**
```python
#!/usr/bin/env python3
from ansible.module_utils.basic import AnsibleModule

def main():
    argument_spec = dict(
        name=dict(type='str', required=True),
        state=dict(type='str', default='present', choices=['present', 'absent']),
        count=dict(type='int', default=1),
    )

    module = AnsibleModule(
        argument_spec=argument_spec,
        supports_check_mode=True
    )

    name = module.params['name']
    state = module.params['state']

    if module.check_mode:
        module.exit_json(changed=True, msg=f"Would manage {name}")

    # Actual logic here
    module.exit_json(changed=True, msg=f"Managed {name}", state=state)

if __name__ == '__main__':
    main()
```

### Verification

```bash
# Test in check mode
ansible-playbook playbook.yml --check

# Full run
ansible-playbook playbook.yml -v

# Test module directly
ansible localhost -m custom_module -a "name=test" -M ./library
```

### Key Takeaway

Custom modules must never use `print()`, must always return `changed`, must
define proper `argument_spec` types, and should support check mode.
