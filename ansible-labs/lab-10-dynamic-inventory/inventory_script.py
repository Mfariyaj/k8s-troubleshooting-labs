#!/usr/bin/env python3
"""Dynamic inventory script for Ansible.
BUG 1: This file is not executable (chmod +x required).
BUG 2: The JSON output format is incorrect - missing '_meta' and 'hostvars'.
BUG 3: Returns a list instead of proper inventory dict format.
"""

import json
import sys

def get_inventory():
    """Return inventory data in WRONG format."""
    # This is WRONG - Ansible expects a dict with group names as keys
    # and '_meta' with 'hostvars', not a plain list
    inventory = [
        {"hostname": "web1", "ip": "192.168.1.100", "group": "webservers"},
        {"hostname": "web2", "ip": "192.168.1.101", "group": "webservers"},
        {"hostname": "db1", "ip": "192.168.1.200", "group": "databases"},
    ]
    return inventory

def get_host(hostname):
    """Return host vars - also in wrong format."""
    hosts = {
        "web1": {"ansible_host": "192.168.1.100", "http_port": 80},
        "web2": {"ansible_host": "192.168.1.101", "http_port": 8080},
        "db1": {"ansible_host": "192.168.1.200", "db_port": 5432},
    }
    return hosts.get(hostname, {})

if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        print(json.dumps(get_inventory()))
    elif len(sys.argv) == 3 and sys.argv[1] == "--host":
        print(json.dumps(get_host(sys.argv[2])))
    else:
        print(json.dumps(get_inventory()))
