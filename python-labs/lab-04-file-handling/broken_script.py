#!/usr/bin/env python3
"""
Configuration File Manager
===========================
This script reads, modifies, and writes server configuration files.

INTENDED BEHAVIOR:
- Read an existing config file
- Update specific values
- Write the modified config to a new file
- Read it back to verify the write
"""

import os


def read_config(filepath):
    """Read a config file and return contents as a dict."""
    config = {}
    
    # BUG 1: Path doesn't exist — using wrong directory
    f = open("/etc/nonexistent/app.conf", 'r')
    content = f.read()
    f.close()
    
    for line in content.split('\n'):
        if '=' in line and not line.startswith('#'):
            key, value = line.strip().split('=', 1)
            config[key.strip()] = value.strip()
    
    return config


def write_config(filepath, config):
    """Write configuration dict to a file."""
    # BUG 2: Not using context manager — file handle leaks if error occurs
    # Also writing to a directory that doesn't exist without creating it
    output_dir = "/tmp/python-lab-04-output"
    output_path = os.path.join(output_dir, "updated.conf")
    
    f = open(output_path, 'w')
    f.write("# Updated Configuration\n")
    for key, value in config.items():
        f.write(f"{key}={value}\n")
    # Missing f.close() — but more importantly, output_dir doesn't exist!


def verify_config(filepath):
    """Read back the file to verify it was written correctly."""
    # BUG 3: Using encoding that doesn't match what was written
    with open(filepath, 'r', encoding='utf-16') as f:
        content = f.read()
    
    print("Verification - file contents:")
    print(content)
    return content


def main():
    print("Configuration File Manager")
    print("=" * 40)
    
    # Create a sample config file for the lab
    sample_config = """# Application Configuration
server_host=10.0.1.100
server_port=8080
database_url=postgres://db.internal:5432/app
log_level=WARNING
max_workers=4
debug_mode=false
"""
    # Write sample config
    sample_path = "/tmp/python-lab-04-input.conf"
    with open(sample_path, 'w') as f:
        f.write(sample_config)
    
    # Step 1: Read config
    print("\n📖 Reading configuration...")
    config = read_config(sample_path)
    print(f"  Loaded {len(config)} settings")
    
    # Step 2: Modify values
    print("\n✏️  Updating configuration...")
    config["log_level"] = "DEBUG"
    config["max_workers"] = "8"
    config["debug_mode"] = "true"
    print("  Updated: log_level, max_workers, debug_mode")
    
    # Step 3: Write new config
    output_path = "/tmp/python-lab-04-output/updated.conf"
    print(f"\n💾 Writing to {output_path}...")
    write_config(output_path, config)
    print("  Write complete!")
    
    # Step 4: Verify
    print("\n🔍 Verifying written file...")
    verify_config(output_path)
    
    print("\n✅ Configuration updated successfully!")


if __name__ == "__main__":
    main()
