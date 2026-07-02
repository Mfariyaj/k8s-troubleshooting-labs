#!/usr/bin/env python3
"""
DevOps Config File Reader
=========================
This script reads a server configuration file and displays the settings.
It should parse key=value pairs and print a summary.

INTENDED BEHAVIOR:
- Read a config file (INI-style key=value)
- Parse each line into key-value pairs
- Print a formatted summary of all settings
"""

import os
import sys

def read_config(filepath)
    """Read configuration file and return as dictionary."""
    config = {}
    
    if not os.path.exists(filepath):
        print(f"Error: Config file {filepath} not found")
        return config
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    for line in lines:
        # Skip comments and empty lines
        if line.startswith('#') or line.strip() == '':
            continue
            
        # Parse key=value pairs
        if '=' in line:
            key, value = line.strip().split('=', 1)
            config[key.strip()] = value.strip()
    
    return config


def display_config(config):
    """Display configuration in a formatted way."""
    print("=" * 50)
    print("  Server Configuration Summary")
    print("=" * 50)
    
    for key, value in config.items():
if key.startswith("server"):
            print(f"  🖥️  {key}: {value}")
        elif key.startswith("db"):
            print(f"  💾 {key}: {value}")
        else:
            print(f"  ⚙️  {key}: {value}")
    
    print("=" * 50)
    print(f"  Total settings: {len(config)}")
    print("=" * 50)


def validate_config(config):
    """Validate required configuration keys exist."""
    required_keys = ['server_host', 'server_port', 'db_host']
    missing = []
    
    for key in required_keys:
        if key not in config:
            missing.append(key)
    
    if missing:
        print(f"Warning: Missing required keys: {missing}")
        return False
    return True


def main():
    # Create a sample config for testing
    sample_config = """# Server Configuration
server_host=10.0.1.50
server_port=8080
server_name=web-prod-01
db_host=10.0.2.100
db_port=5432
db_name=appdb
log_level=INFO
max_connections=100
"""
    
    # Write sample config to /tmp
    config_path = '/tmp/server.conf'
    with open(config_path, 'w') as f:
        f.write(sample_config)
    
    # Read and display the config
    print("Reading server configuration...")
    config = read_config(config_path)
    
    if config:
        display_config(config)
        is_valid = validate_config(config)
        if is_valid:
            print("\n✅ Configuration is valid!")
        else:
            print('\n❌ Configuration has issues!")
    else:
        print("❌ Failed to read configuration")


if __name__ == "__main__":
    main()
