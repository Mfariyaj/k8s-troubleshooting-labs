#!/usr/bin/env python3
"""
Server Inventory Manager
=========================
This script processes a server inventory list — filters, groups,
and generates reports about server infrastructure.

INTENDED BEHAVIOR:
- Process a list of servers
- Filter by status (active vs decommissioned)
- Group by environment
- Print summary report
"""


def get_server_inventory():
    """Return a list of server dictionaries."""
    return [
        {"name": "web-01", "env": "production", "cpu": 4, "ram": 16, "status": "active"},
        {"name": "web-02", "env": "production", "cpu": 4, "ram": 16, "status": "active"},
        {"name": "api-01", "env": "production", "cpu": 8, "ram": 32, "status": "active"},
        {"name": "db-01", "env": "production", "cpu": 16, "ram": 64, "status": "active"},
        {"name": "cache-01", "env": "production", "cpu": 4, "ram": 32, "status": "active"},
        {"name": "dev-01", "env": "development", "cpu": 2, "ram": 8, "status": "active"},
        {"name": "dev-02", "env": "development", "cpu": 2, "ram": 8, "status": "active"},
        {"name": "staging-01", "env": "staging", "cpu": 4, "ram": 16, "status": "active"},
        {"name": "old-web-01", "env": "production", "cpu": 2, "ram": 4, "status": "decommissioned"},
        {"name": "old-db-01", "env": "production", "cpu": 8, "ram": 16, "status": "decommissioned"},
    ]


def filter_active_servers(servers):
    """Remove decommissioned servers from the list."""
    # BUG 1: Modifying list while iterating over it — causes items to be skipped
    for server in servers:
        if server["status"] == "decommissioned":
            servers.remove(server)
    return servers


def get_top_servers_by_ram(servers, count):
    """Get the top N servers by RAM."""
    sorted_servers = sorted(servers, key=lambda s: s["ram"], reverse=True)
    # BUG 2: Off-by-one / IndexError — count could be larger than list
    top_servers = []
    for i in range(count):
        top_servers.append(sorted_servers[i])  # Fails if count > len(sorted_servers)
    return top_servers


def group_by_environment(servers):
    """Group servers by their environment."""
    groups = {}
    for server in servers:
        env = server["env"]
        # BUG 3: This creates a new list each iteration instead of appending
        groups[env] = [server]
    return groups


def calculate_total_resources(servers):
    """Calculate total CPU and RAM across all servers."""
    # This uses a list comprehension — showing the correct pattern
    total_cpu = sum([s["cpu"] for s in servers])
    total_ram = sum([s["ram"] for s in servers])
    return total_cpu, total_ram


def print_report(servers):
    """Print a formatted server inventory report."""
    print("=" * 60)
    print("  Server Inventory Report")
    print("=" * 60)
    
    # Filter active servers
    active = filter_active_servers(servers)
    print(f"\n  Active servers: {len(active)}")
    
    # Group by environment
    groups = group_by_environment(active)
    print(f"\n  Environments:")
    for env, env_servers in groups.items():
        print(f"    {env}: {len(env_servers)} servers")
    
    # Top 3 by RAM
    print(f"\n  Top 3 servers by RAM:")
    top = get_top_servers_by_ram(active, 3)
    for s in top:
        print(f"    {s['name']}: {s['ram']}GB RAM")
    
    # Totals
    total_cpu, total_ram = calculate_total_resources(active)
    print(f"\n  Total resources:")
    print(f"    CPU: {total_cpu} cores")
    print(f"    RAM: {total_ram} GB")
    
    print("\n" + "=" * 60)


def main():
    servers = get_server_inventory()
    print("Processing server inventory...")
    print_report(servers)


if __name__ == "__main__":
    main()
