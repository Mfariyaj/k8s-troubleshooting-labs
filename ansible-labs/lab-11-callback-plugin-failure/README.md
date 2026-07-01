# Lab 11: Custom Callback Plugin Failure ⭐⭐⭐⭐⭐

## Difficulty: Expert

## Scenario

Your team has developed a custom Ansible callback plugin (`custom_logger`) that sends JSON-formatted task execution events to an external logging/SIEM system via HTTP POST. The plugin was working in the development environment but after upgrading Ansible and deploying to the CI/CD pipeline, it has stopped firing events entirely.

**The insidious part:** The playbook runs to completion with no visible errors. Tasks succeed, but the callback plugin silently fails to send any events to the logging system. The operations team is blind to what Ansible is doing in production.

## What You'll Observe

When you run the playbook:
```
$ ansible-playbook playbook.yml -v

[WARNING]: The `callback_whitelist` option is deprecated, use `callbacks_enabled` instead.

PLAY [Application deployment with event logging] *******************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Create application directories] ******************************************
changed: [localhost] => (item=/tmp/ansible-lab11/config)
changed: [localhost] => (item=/tmp/ansible-lab11/logs)

TASK [Generate application configuration] **************************************
changed: [localhost]

...

PLAY RECAP *********************************************************************
localhost                  : ok=6    changed=3    unreachable=0    failed=0    skipped=0
```

Everything looks normal — but **zero callback events were sent to the logging system**. With increased verbosity (`-vvv`):

```
$ ansible-playbook playbook.yml -vvv 2>&1 | grep -i callback

[WARNING]: The `callback_whitelist` option is deprecated, use `callbacks_enabled` instead.
[WARNING]: Skipping callback plugin 'custom_logger': Failed to import callback plugin "custom_logger": No module named 'requests_toolbelt'
```

Or alternatively, if the import were fixed but CALLBACK_TYPE is wrong:
```
[WARNING]: Skipping callback plugin 'custom_logger', as it has a CALLBACK_TYPE of 'stdout' which is already loaded by the 'default' plugin.
```

## Environment

- Ansible 2.15+ (core 2.15.x or later)
- Python 3.9+
- Custom callback plugin in `./callback_plugins/`
- Target logging endpoint: `http://logging-system.internal:9200`

## Files to Investigate

| File | Purpose |
|------|---------|
| `callback_plugins/custom_logger.py` | The broken callback plugin |
| `ansible.cfg` | Ansible configuration with callback settings |
| `playbook.yml` | Playbook that should trigger events |

## Hints

<details>
<summary>Hint 1</summary>
Run with maximum verbosity (`-vvvv`) and grep for "callback" and "Skipping" in the output. Ansible silently skips plugins that fail to import. Check what Python modules the plugin is trying to import.
</details>

<details>
<summary>Hint 2</summary>
There are TWO separate issues with CALLBACK_TYPE. The class-level attribute says 'stdout', but non-stdout callback plugins MUST use 'notification' or 'aggregate'. When type is 'stdout', it conflicts with the default stdout callback and gets skipped.
</details>

<details>
<summary>Hint 3</summary>
The method signatures for v2_runner_on_ok and v2_runner_on_failed don't match the Ansible callback API. Check the CallbackBase source code — v2_runner_on_ok takes only (self, result), not extra parameters. Wrong signatures cause silent failures in callback dispatch.
</details>

## Useful Commands

```bash
# Run with maximum verbosity to see callback loading
ansible-playbook playbook.yml -vvvv 2>&1 | grep -i "callback\|plugin\|skip\|import\|error"

# Check if callback plugin is being discovered
ansible-doc -t callback -l 2>&1 | grep custom

# Verify Python can import the plugin
python3 -c "import callback_plugins.custom_logger"

# Check Python import availability
python3 -c "from requests_toolbelt.multipart import encoder"

# List installed Python packages
pip3 list | grep -i requests

# Check Ansible configuration being used
ansible-config dump | grep -i callback

# View current callback settings
ansible-config list | grep -A5 -i "callbacks_enabled\|callback_whitelist"

# Check deprecated settings
ansible-config dump --only-changed

# Validate callback plugin structure
python3 -c "
import inspect
from ansible.plugins.callback import CallbackBase
print([m for m in dir(CallbackBase) if m.startswith('v2_runner')])
"

# Check correct method signatures
python3 -c "
import inspect
from ansible.plugins.callback import CallbackBase
sig = inspect.signature(CallbackBase.v2_runner_on_ok)
print(f'v2_runner_on_ok signature: {sig}')
sig = inspect.signature(CallbackBase.v2_runner_on_failed)
print(f'v2_runner_on_failed signature: {sig}')
"

# Test callback plugin in isolation
ANSIBLE_CALLBACK_PLUGINS=./callback_plugins ANSIBLE_CALLBACKS_ENABLED=custom_logger ansible-playbook playbook.yml -vvvv

# Check for CALLBACK_TYPE conflicts
grep -n "CALLBACK_TYPE" callback_plugins/custom_logger.py

# Verify ansible.cfg is being read
ansible --version
```

## What You Need to Fix

1. **Python import error** — The plugin imports a module that isn't available
2. **CALLBACK_TYPE conflict** — The type is set to 'stdout' causing it to be skipped
3. **Deprecated configuration** — `callback_whitelist` is deprecated in Ansible 2.15+
4. **Method signatures** — Callback methods have incorrect parameter signatures

## Success Criteria

- [ ] Callback plugin loads without import errors
- [ ] Plugin does not conflict with stdout callback
- [ ] ansible.cfg uses correct modern configuration option
- [ ] Callback methods match the Ansible callback API signatures
- [ ] Running playbook with `-vvv` shows callback plugin is active
- [ ] Events are dispatched (even if external endpoint is unreachable, no import/load errors)
