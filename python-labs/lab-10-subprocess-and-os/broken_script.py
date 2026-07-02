#!/usr/bin/env python3
"""
System Command Runner for DevOps
==================================
This script runs system commands (like kubectl, docker, git) via subprocess
and processes the output for reporting.

INTENDED BEHAVIOR:
- Run system commands safely using subprocess
- Capture output for parsing
- Handle command failures gracefully
- Generate a system status report
"""

import subprocess
import os
import shlex


def get_disk_usage():
    """Get disk usage using df command."""
    # BUG 1: Using shell=True with string when it's not needed
    # Plus the command string is not split properly for shell=False
    result = subprocess.run(
        "df -h /tmp",  # This is a string, but shell=False (default) requires a list
        capture_output=True,
        text=True
    )
    return result.stdout


def get_running_processes(search_term):
    """Search for running processes matching a term."""
    # BUG 2: Shell injection vulnerability — user input goes directly into shell command
    # Also, check=True with shell=True will crash if grep finds nothing (exit code 1)
    cmd = f"ps aux | grep {search_term} | grep -v grep"
    result = subprocess.run(
        cmd,
        shell=True,
        check=True,  # grep returns exit code 1 if no match — this will raise!
        capture_output=True,
        text=True
    )
    return result.stdout


def get_system_info():
    """Get hostname and OS info."""
    # BUG 3: Using os.path.join incorrectly for commands, and wrong approach to get output
    hostname_cmd = os.path.join("/usr", "bin", "hostname")
    
    # This runs the command but doesn't capture output properly
    result = subprocess.run(
        [hostname_cmd],
        capture_output=True,
        text=True,
        check=True
    )
    hostname = result.stdout.strip()
    
    # Get uptime
    uptime_result = subprocess.run(
        ["uptime", "-p"],
        capture_output=True,
        text=True
    )
    uptime = uptime_result.stdout.strip()
    
    return {"hostname": hostname, "uptime": uptime}


def run_health_check(commands):
    """Run a list of health check commands and report results."""
    results = []
    
    for name, cmd in commands.items():
        try:
            # This works correctly — showing the proper pattern
            cmd_list = shlex.split(cmd)
            result = subprocess.run(
                cmd_list,
                capture_output=True,
                text=True,
                timeout=10
            )
            results.append({
                "name": name,
                "status": "ok" if result.returncode == 0 else "failed",
                "output": result.stdout.strip()[:100],
                "error": result.stderr.strip()[:100] if result.returncode != 0 else ""
            })
        except subprocess.TimeoutExpired:
            results.append({"name": name, "status": "timeout", "output": "", "error": "Command timed out"})
        except FileNotFoundError:
            results.append({"name": name, "status": "not_found", "output": "", "error": "Command not found"})
    
    return results


def main():
    print("=" * 55)
    print("  System Status Report")
    print("=" * 55)
    
    # Get system info
    print("\n📊 System Info:")
    try:
        info = get_system_info()
        print(f"  Hostname: {info['hostname']}")
        print(f"  Uptime:   {info['uptime']}")
    except Exception as e:
        print(f"  ⚠️  Could not get system info: {e}")
    
    # Get disk usage
    print("\n💾 Disk Usage (/tmp):")
    try:
        disk = get_disk_usage()
        for line in disk.strip().split('\n'):
            print(f"  {line}")
    except Exception as e:
        print(f"  ⚠️  Could not get disk usage: {e}")
    
    # Search for python processes
    print("\n🔍 Python Processes:")
    try:
        procs = get_running_processes("python")
        if procs.strip():
            for line in procs.strip().split('\n')[:5]:
                print(f"  {line[:80]}")
        else:
            print("  No Python processes found")
    except subprocess.CalledProcessError:
        print("  No Python processes found (grep returned no matches)")
    except Exception as e:
        print(f"  ⚠️  Error searching processes: {e}")
    
    # Run health checks
    print("\n🏥 Health Checks:")
    checks = {
        "Date": "date +%Y-%m-%d",
        "Whoami": "whoami",
        "Free Memory": "free -h",
        "Kubectl": "kubectl version --client",
    }
    
    results = run_health_check(checks)
    for r in results:
        icon = "✅" if r["status"] == "ok" else "❌"
        print(f"  {icon} {r['name']}: {r['status']}")
        if r["output"]:
            print(f"     → {r['output'][:60]}")
        if r["error"]:
            print(f"     ⚠️  {r['error'][:60]}")
    
    print("\n" + "=" * 55)


if __name__ == "__main__":
    main()
