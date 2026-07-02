"""
Utility functions for health checking.
"""

from config import SERVER_LIST

DEFAULT_TIMEOUT = 5


def check_server_health(server, timeout):
    """Check if a server is responding."""
    # Simulate health check (in real life, this would use socket/requests)
    import random
    random.seed(hash(server["host"]))
    
    is_healthy = random.random() > 0.3
    
    return {
        "name": server["name"],
        "host": server["host"],
        "port": server["port"],
        "status": "healthy" if is_healthy else "unhealthy",
        "response_time": round(random.uniform(0.01, 2.0), 3) if is_healthy else None
    }


def format_output(results):
    """Format health check results for display."""
    lines = []
    for r in results:
        if r["status"] == "healthy":
            lines.append(f"  ✅ {r['name']} ({r['host']}:{r['port']}) — {r['response_time']}s")
        else:
            lines.append(f"  ❌ {r['name']} ({r['host']}:{r['port']}) — UNREACHABLE")
    return "\n".join(lines)
