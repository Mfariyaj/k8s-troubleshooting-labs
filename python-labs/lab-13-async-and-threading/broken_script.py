#!/usr/bin/env python3
"""
Parallel Health Checker — Async & Threading
=============================================
This script performs health checks on multiple servers concurrently.

INTENDED BEHAVIOR:
- Check multiple server endpoints in parallel
- Use asyncio for concurrent I/O operations
- Collect results safely using proper synchronization
- Display a real-time dashboard
"""

import asyncio
import time
import random
from concurrent.futures import ThreadPoolExecutor


# Simulated server list
SERVERS = [
    {"name": "web-01", "host": "10.0.1.10", "port": 8080},
    {"name": "web-02", "host": "10.0.1.11", "port": 8080},
    {"name": "api-01", "host": "10.0.2.10", "port": 3000},
    {"name": "db-01", "host": "10.0.3.10", "port": 5432},
    {"name": "cache-01", "host": "10.0.4.10", "port": 6379},
]


# BUG 1: Shared mutable state without synchronization
results = []


def simulate_health_check(server):
    """Simulate a network health check (blocking I/O)."""
    # Simulate network latency
    latency = random.uniform(0.1, 0.5)
    time.sleep(latency)
    
    # Simulate random health status
    random.seed(hash(server["name"]) + int(time.time()) // 10)
    is_healthy = random.random() > 0.2
    
    return {
        "name": server["name"],
        "host": server["host"],
        "healthy": is_healthy,
        "latency_ms": round(latency * 1000, 1)
    }


def check_server_threaded(server):
    """Run health check in a thread and append to shared results."""
    # BUG 1: Appending to shared list from multiple threads — race condition
    result = simulate_health_check(server)
    results.append(result)  # Not thread-safe! (though CPython's GIL makes this mostly safe)
    return result


# BUG 2: async function that doesn't await — just calls sync function directly
async def check_server_async(server):
    """Check a single server using asyncio."""
    # This calls a blocking function directly in an async context!
    # It blocks the entire event loop — no concurrency benefit
    result = simulate_health_check(server)
    return result


async def check_all_servers_async():
    """Check all servers concurrently using asyncio."""
    # BUG 3: Running tasks sequentially instead of concurrently
    # Using a loop with await runs each check one at a time!
    tasks = []
    for server in SERVERS:
        result = await check_server_async(server)
        tasks.append(result)
    
    return tasks


def check_all_servers_threaded():
    """Check all servers concurrently using threads."""
    global results
    results = []  # Reset shared state
    
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = []
        for server in SERVERS:
            future = executor.submit(check_server_threaded, server)
            futures.append(future)
        
        # Wait for all to complete
        for future in futures:
            future.result()  # This also propagates exceptions
    
    return results


def display_results(check_results, method_name, elapsed):
    """Display health check results."""
    print(f"\n  📊 Results ({method_name}) — {elapsed:.2f}s:")
    print(f"  {'Server':<12} {'Host':<15} {'Status':<10} {'Latency'}")
    print(f"  {'-'*12} {'-'*15} {'-'*10} {'-'*10}")
    
    for r in check_results:
        status = "✅ OK" if r["healthy"] else "❌ DOWN"
        print(f"  {r['name']:<12} {r['host']:<15} {status:<10} {r['latency_ms']}ms")
    
    healthy = sum(1 for r in check_results if r["healthy"])
    print(f"\n  Summary: {healthy}/{len(check_results)} healthy")


def main():
    print("=" * 55)
    print("  Parallel Health Checker")
    print("=" * 55)
    
    # Method 1: Sequential (baseline)
    print("\n⏱️  Method 1: Sequential checks...")
    start = time.time()
    sequential_results = []
    for server in SERVERS:
        result = simulate_health_check(server)
        sequential_results.append(result)
    elapsed = time.time() - start
    display_results(sequential_results, "Sequential", elapsed)
    
    # Method 2: ThreadPoolExecutor
    print("\n⏱️  Method 2: Threaded checks...")
    start = time.time()
    threaded_results = check_all_servers_threaded()
    elapsed = time.time() - start
    display_results(threaded_results, "Threaded", elapsed)
    
    # Method 3: asyncio
    print("\n⏱️  Method 3: Async checks...")
    start = time.time()
    async_results = asyncio.run(check_all_servers_async())
    elapsed = time.time() - start
    display_results(async_results, "Async", elapsed)
    
    print("\n" + "=" * 55)
    print("  💡 Threaded should be faster than Sequential for I/O!")
    print("  💡 Async should also be fast — but is it? Check the time!")
    print("=" * 55)


if __name__ == "__main__":
    main()
