## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (sets up environment and runs broken playbook)
2. Read the Ansible error output carefully
3. Investigate: Check playbook.yml, inventory, roles, templates
4. Fix the broken configuration
5. Re-run: `ansible-playbook playbook.yml` to verify
6. Check `solution.md` if stuck

---

# Lab 12: Custom Ansible Module Broken ⭐⭐⭐⭐⭐

## Difficulty: Expert

## Scenario

Your team has written a custom Ansible module called `custom_config` that manages application configuration files. The module was working with Ansible 2.9 but has broken after upgrading. It exhibits multiple failures:

1. **JSON parsing error** — Ansible can't parse the module's output
2. **Idempotency failure** — The module always reports "changed" even when config hasn't changed
3. **Check mode unsupported** — Running with `--check` actually modifies files
4. **Type coercion issues** — Dictionary arguments are being treated as strings

This is a production module used across 200+ playbooks. Fixing it requires understanding Ansible's module development internals.

## What You'll Observe

```
$ ansible-playbook playbook.yml -v

PLAY [Configure application settings] *****************************************

TASK [Ensure config directory exists] ******************************************
ok: [localhost]

TASK [Deploy database configuration] ******************************************
An exception occurred during task execution. The full traceback is:
...
fatal: [localhost]: FAILED! => {"msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "module_stdout": "custom_config module loading...\n{\"path\": \"/tmp/ansible-lab12/config/database.ini\", ...}", "module_stderr": "", "rc": 0}

The error appears to be: Unable to parse module output as JSON.
The module output was not valid JSON: Expecting value: line 1 column 1 (char 0)
```

Or with the type bug:
```
fatal: [localhost]: FAILED! => {"changed": false, "msg": "argument 'settings' is of type <class 'dict'> and we were unable to convert to str: ..."}
```

## Environment

- Ansible 2.15+ (ansible-core)
- Python 3.9+
- Custom module in `./library/`
- Local connection (localhost)

## Files to Investigate

| File | Purpose |
|------|---------|
| `library/custom_config.py` | The broken custom module |
| `playbook.yml` | Playbook that uses the module |

## Hints

<details>
<summary>Hint 1</summary>
Ansible captures everything on stdout from a module and expects it to be valid JSON. ANY print() statement that writes to stdout before the module's JSON response will corrupt the output. Search for print() calls in the module that write to sys.stdout.
</details>

<details>
<summary>Hint 2</summary>
The `argument_spec` defines `settings` as `type='str'` but the playbook passes a dictionary. Ansible will try to coerce the dict to a string and fail. The type should be `type='dict'`. Similarly, `backup` should be `type='bool'` with a proper boolean default.
</details>

<details>
<summary>Hint 3</summary>
For idempotency, module.exit_json() MUST include a 'changed' key. Without it, Ansible defaults to 'changed: false' but the module gives no indication of actual state. Additionally, `supports_check_mode=True` must be set AND the module must check `module.check_mode` to skip actual file operations during dry-run.
</details>

## Useful Commands

```bash
# Run the playbook and observe errors
ansible-playbook playbook.yml -v

# Run with full module debug output
ANSIBLE_KEEP_REMOTE_FILES=1 ansible-playbook playbook.yml -vvvv

# Test module directly with ansible command
ansible localhost -m custom_config -a "path=/tmp/test.ini settings='{\"key\":\"val\"}' format=ini" -M ./library

# Check module documentation
ansible-doc -M ./library custom_config

# Validate module syntax
python3 -c "import library.custom_config"

# Test module output manually
echo '{"path":"/tmp/test.ini","settings":{"key":"val"},"format":"ini","backup":"true","validate":true}' | python3 library/custom_config.py

# Run in check mode to test check_mode support
ansible-playbook playbook.yml --check -v

# Check for stdout pollution
python3 -c "
import sys, io
old_stdout = sys.stdout
sys.stdout = io.StringIO()
exec(open('library/custom_config.py').read())
output = sys.stdout.getvalue()
sys.stdout = old_stdout
if output:
    print(f'POLLUTION DETECTED: {repr(output)}')
"

# Verify JSON output format
python3 -c "
import json, subprocess
# Check what module actually outputs
result = subprocess.run(['python3', 'library/custom_config.py'], 
    input=json.dumps({'ANSIBLE_MODULE_ARGS': {'path': '/tmp/t.ini', 'settings': {'k':'v'}, 'format': 'ini', 'backup': 'true', 'validate': True}}),
    capture_output=True, text=True)
print('STDOUT:', repr(result.stdout[:200]))
print('STDERR:', repr(result.stderr[:200]))
"

# Check if changed key exists in output
ansible-playbook playbook.yml -v 2>&1 | grep -i "changed"

# Run twice and compare
ansible-playbook playbook.yml && ansible-playbook playbook.yml
```

## What You Need to Fix

1. **Remove stdout pollution** — All print() statements to stdout before JSON output
2. **Fix argument_spec types** — `settings` must be `type='dict'`, `backup` must be `type='bool'`
3. **Add check_mode support** — Set `supports_check_mode=True` and handle `module.check_mode`
4. **Add 'changed' key** — Calculate whether the file actually changed and include in result
5. **Implement idempotency** — Compare existing file content before writing

## Success Criteria

- [ ] Module runs without JSON parsing errors
- [ ] `ansible-playbook playbook.yml --check` doesn't modify any files
- [ ] Running the playbook twice shows `changed=0` on second run (idempotent)
- [ ] Dictionary settings are properly handled without type coercion errors
- [ ] Module output is clean JSON with no extra text
- [ ] `changed` key accurately reflects whether modifications occurred
