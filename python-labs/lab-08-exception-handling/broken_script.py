#!/usr/bin/env python3
"""
Service Health Check API Client
=================================
This script checks multiple service endpoints and reports their health.
It simulates calling REST APIs and handling various failure modes.

INTENDED BEHAVIOR:
- Check multiple service endpoints
- Handle various error types gracefully
- Report overall health status with details
- Retry failed checks
"""

import json
import time
import sys


class ServiceCheckError(Exception):
    """Custom exception for service check failures."""
    pass


def check_endpoint(service_name, url, timeout=5):
    """Simulate checking a service endpoint."""
    # Simulated responses based on service name
    simulated_responses = {
        "auth-service": {"status": 200, "body": {"healthy": True, "version": "v2.1"}},
        "payment-api": {"status": 503, "body": None},  # Service unavailable
        "user-db": {"status": 200, "body": {"healthy": True, "connections": 42}},
        "cache-redis": None,  # Simulates connection timeout
        "search-engine": {"status": 200, "body": "not json"},  # Bad response body
    }
    
    response = simulated_responses.get(service_name)
    
    if response is None:
        raise ConnectionError(f"Connection to {url} timed out after {timeout}s")
    
    if response["status"] >= 500:
        raise ServiceCheckError(f"{service_name} returned HTTP {response['status']}")
    
    return response


def parse_health_response(response):
    """Parse the health check response body."""
    body = response["body"]
    
    # BUG 1: Catching wrong exception type — json.loads raises JSONDecodeError/ValueError
    # but we catch TypeError which won't match
    try:
        if isinstance(body, str):
            data = json.loads(body)  # This will raise json.JSONDecodeError
        else:
            data = body
    except TypeError:
        # This except will NEVER catch JSONDecodeError!
        return {"healthy": False, "error": "Invalid response format"}
    
    return data


def check_all_services():
    """Check all services and collect results."""
    services = {
        "auth-service": "http://auth.internal:8080/health",
        "payment-api": "http://payment.internal:8080/health",
        "user-db": "http://userdb.internal:5432/health",
        "cache-redis": "http://redis.internal:6379/health",
        "search-engine": "http://search.internal:9200/health",
    }
    
    results = []
    
    for name, url in services.items():
        # BUG 2: Bare except catches everything including KeyboardInterrupt and SystemExit
        # Also swallows the error completely — we lose all diagnostic info
        try:
            response = check_endpoint(name, url)
            health = parse_health_response(response)
            results.append({"service": name, "status": "healthy", "details": health})
        except:
            results.append({"service": name, "status": "unknown"})
    
    return results


def retry_failed_checks(results, services, max_retries=3):
    """Retry checks for services that failed."""
    failed = [r for r in results if r["status"] != "healthy"]
    
    for service_result in failed:
        name = service_result["service"]
        
        for attempt in range(max_retries):
            # BUG 3: No exception handling at all — first failure crashes the whole function
            # and no finally block to log the attempt
            url = f"http://{name}.internal/health"
            response = check_endpoint(name, url)
            health = parse_health_response(response)
            service_result["status"] = "healthy"
            service_result["details"] = health
            break
    
    return results


def print_health_report(results):
    """Print formatted health check report."""
    print("=" * 55)
    print("  Service Health Report")
    print("=" * 55)
    
    for r in results:
        if r["status"] == "healthy":
            icon = "✅"
        elif r["status"] == "unhealthy":
            icon = "❌"
        else:
            icon = "⚠️ "
        
        details = r.get("details", {})
        detail_str = ""
        if isinstance(details, dict):
            if "version" in details:
                detail_str = f" (v{details['version']})"
            elif "error" in details:
                detail_str = f" — {details['error']}"
        
        print(f"  {icon} {r['service']}: {r['status']}{detail_str}")
    
    print("=" * 55)
    healthy_count = sum(1 for r in results if r["status"] == "healthy")
    total = len(results)
    print(f"  Overall: {healthy_count}/{total} services healthy")
    
    if healthy_count < total:
        print("  ⚠️  ACTION REQUIRED: Some services need attention!")
    print("=" * 55)


def main():
    print("🔍 Checking service health...\n")
    
    results = check_all_services()
    
    # Try to retry failed services
    services = {r["service"]: f"http://{r['service']}.internal/health" for r in results}
    final_results = retry_failed_checks(results, services)
    
    print_health_report(final_results)


if __name__ == "__main__":
    main()
