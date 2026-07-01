# Lab 10: Dynamic Inventory Script Failure

## Difficulty: ⭐⭐⭐ Hard

## Scenario
You're using a custom Python dynamic inventory script instead of a static `inventory.ini`. The script fails for two reasons: it's not marked executable (`chmod +x`), and it returns invalid JSON format — a list instead of the proper Ansible inventory dictionary structure with `_meta` and `hostvars` keys.

## Expected Error Output
```
[WARNING]: * Failed to parse /path/to/inventory_script.py with script plugin: 
problem running /path/to/inventory_script.py --list ([Errno 13] Permission denied)

[WARNING]: * Failed to parse /path/to/inventory_script.py with auto plugin: 
problem running /path/to/inventory_script.py --list

[WARNING]: Unable to parse /path/to/inventory_script.py as an inventory source

[WARNING]: No inventory was parsed, only implicit localhost is available

[WARNING]: provided hosts list is empty, only localhost is available

PLAY [Deploy application using dynamic inventory] ******************************
skipping: no hosts matched
```

## Hints
1. The script needs execute permission: `chmod +x inventory_script.py`.
2. The `--list` output must be a JSON dict with group names as keys, not a plain list.
3. Proper format: `{"webservers": {"hosts": ["web1"]}, "_meta": {"hostvars": {"web1": {...}}}}`.

## Troubleshooting Commands
```bash
ls -la inventory_script.py
python3 inventory_script.py --list | python3 -m json.tool
chmod +x inventory_script.py && ./inventory_script.py --list
ansible-inventory -i inventory_script.py --list
ansible-inventory -i inventory_script.py --graph
```
