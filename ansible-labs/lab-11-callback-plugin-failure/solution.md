## Solution: Callback Plugin Failure

### Root Cause

The custom callback plugin fails to load due to:
1. **Import error** — missing or incorrect module import in the plugin
2. **Not enabled** — `callbacks_enabled` not set in ansible.cfg
3. **Wrong method signatures** — callback methods don't match the expected API
   (e.g., `v2_runner_on_ok(self, result)` not `v2_runner_on_ok(self, task, result)`)

### Step-by-Step Fix

1. **Fix the import error in the callback plugin:**
```python
from ansible.plugins.callback import CallbackBase
# Not: from ansible.plugins.callback import CallbackModule
```

2. **Enable the plugin in ansible.cfg:**
```ini
[defaults]
callbacks_enabled = custom_callback
callback_plugins = ./callback_plugins
```

3. **Fix method signatures to match Ansible v2 API:**
```python
def v2_runner_on_ok(self, result):
    host = result._host.get_name()
    self._display.display(f"{host} | SUCCESS")

def v2_runner_on_failed(self, result, ignore_errors=False):
    host = result._host.get_name()
    self._display.display(f"{host} | FAILED")
```

### Fixed Configuration

**callback_plugins/custom_callback.py:**
```python
from ansible.plugins.callback import CallbackBase

class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'custom_callback'

    def v2_runner_on_ok(self, result):
        host = result._host.get_name()
        task = result._task.get_name()
        self._display.display(f"OK: {host} - {task}")

    def v2_runner_on_failed(self, result, ignore_errors=False):
        host = result._host.get_name()
        self._display.display(f"FAILED: {host}")

    def v2_playbook_on_stats(self, stats):
        self._display.display("Playbook complete.")
```

**ansible.cfg:**
```ini
[defaults]
callbacks_enabled = custom_callback
callback_plugins = ./callback_plugins
```

### Verification

```bash
ansible-playbook playbook.yml -v
# Custom callback output should appear without import errors
```

### Key Takeaway

Callback plugins must use v2 API signatures, inherit from `CallbackBase`, and
be explicitly enabled via `callbacks_enabled` in ansible.cfg.
