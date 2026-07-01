#!/usr/bin/python
# -*- coding: utf-8 -*-

# Custom Ansible module: custom_config
# Manages application configuration files with validation

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: custom_config
short_description: Manage application configuration files
description:
    - Creates and manages application configuration files
    - Validates configuration syntax before writing
    - Supports multiple configuration formats (ini, yaml, json)
version_added: "1.0.0"
options:
    path:
        description: Path to the configuration file
        required: true
        type: str
    settings:
        description: Dictionary of configuration settings
        required: true
        type: dict
    format:
        description: Configuration file format
        required: false
        type: str
        choices: ['ini', 'yaml', 'json']
        default: ini
    backup:
        description: Create backup before modifying
        required: false
        type: bool
        default: true
    validate:
        description: Validate configuration after writing
        required: false
        type: bool
        default: true
author:
    - DevOps Team
'''

EXAMPLES = r'''
- name: Set application config
  custom_config:
    path: /etc/myapp/config.ini
    settings:
      database_host: localhost
      database_port: 5432
      log_level: INFO
    format: ini
    backup: true
'''

import json
import os
import shutil
import sys

# BUG 1: Print statement before JSON output breaks Ansible's stdout parsing
# Ansible expects ONLY valid JSON on stdout from modules
print("custom_config module loading...", file=sys.stdout)

from ansible.module_utils.basic import AnsibleModule


def validate_config(path, fmt):
    """Validate the written configuration file"""
    if not os.path.exists(path):
        return False, "File does not exist"
    
    with open(path, 'r') as f:
        content = f.read()
    
    if fmt == 'json':
        try:
            json.loads(content)
            return True, "Valid JSON"
        except json.JSONDecodeError as e:
            return False, f"Invalid JSON: {e}"
    elif fmt == 'ini':
        # Basic INI validation
        for line in content.split('\n'):
            line = line.strip()
            if line and not line.startswith('#') and not line.startswith('['):
                if '=' not in line:
                    return False, f"Invalid INI line: {line}"
        return True, "Valid INI"
    return True, "No validation for format"


def write_config(path, settings, fmt, backup):
    """Write configuration to file"""
    # Create backup if requested and file exists
    if backup and os.path.exists(path):
        backup_path = path + '.bak'
        shutil.copy2(path, backup_path)
    
    # Ensure directory exists
    dir_path = os.path.dirname(path)
    if dir_path and not os.path.exists(dir_path):
        os.makedirs(dir_path)
    
    if fmt == 'ini':
        with open(path, 'w') as f:
            f.write("# Managed by Ansible custom_config module\n")
            for key, value in settings.items():
                f.write(f"{key} = {value}\n")
    elif fmt == 'json':
        with open(path, 'w') as f:
            json.dump(settings, f, indent=2)
    elif fmt == 'yaml':
        with open(path, 'w') as f:
            for key, value in settings.items():
                f.write(f"{key}: {value}\n")
    
    return True


def main():
    # BUG 2: argument_spec has wrong types - 'settings' should be 'dict' not 'str'
    # and 'backup' should be 'bool' not 'str'
    module_args = dict(
        path=dict(type='str', required=True),
        settings=dict(type='str', required=True),  # BUG: should be type='dict'
        format=dict(type='str', required=False, default='ini',
                   choices=['ini', 'yaml', 'json']),
        backup=dict(type='str', required=False, default='true'),  # BUG: should be type='bool', default=True
        validate=dict(type='bool', required=False, default=True),
    )

    # BUG 3: No check_mode support - supports_check_mode should be True
    # and module should handle check_mode gracefully
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False  # BUG: Should be True
    )

    path = module.params['path']
    settings = module.params['settings']
    fmt = module.params['format']
    backup = module.params['backup']
    validate = module.params['validate']

    # No check_mode handling - BUG 3 continued
    # Should have: if module.check_mode: module.exit_json(changed=would_change, ...)

    try:
        # Determine if file would change
        file_exists = os.path.exists(path)
        
        write_config(path, settings, fmt, backup)
        
        if validate:
            valid, msg = validate_config(path, fmt)
            if not valid:
                module.fail_json(msg=f"Configuration validation failed: {msg}")
        
        # BUG 4: Missing 'changed' key in the result
        # Ansible requires 'changed' to be present for idempotency
        result = {
            'path': path,
            'format': fmt,
            'message': 'Configuration written successfully',
            'backup_created': backup and file_exists,
            # 'changed' key is MISSING - this breaks idempotency reporting
        }
        
        # BUG 4 continued: Using print instead of module.exit_json properly
        # This outputs additional text that corrupts the JSON response
        print(f"DEBUG: Config written to {path}")
        
        module.exit_json(**result)

    except Exception as e:
        module.fail_json(msg=f"Failed to write configuration: {str(e)}")


if __name__ == '__main__':
    main()
