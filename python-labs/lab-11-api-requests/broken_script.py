#!/usr/bin/env python3
"""
REST API Client for DevOps Monitoring
=======================================
This script calls REST APIs to gather metrics and status from services.

INTENDED BEHAVIOR:
- Query multiple REST APIs (simulated)
- Handle timeouts, auth failures, and bad responses
- Produce a unified status report

NOTE: This lab simulates API responses to work without network access.
"""

import json
import time
from urllib.request import urlopen, Request
from urllib.error import URLError, HTTPError


class MockResponse:
    """Simulates an HTTP response for testing."""
    def __init__(self, status_code, body, headers=None):
        self.status_code = status_code
        self._body = body
        self.headers = headers or {"Content-Type": "application/json"}
        self.text = body if isinstance(body, str) else json.dumps(body)
    
    def json(self):
        """Parse response body as JSON."""
        if isinstance(self._body, dict) or isinstance(self._body, list):
            return self._body
        return json.loads(self._body)


def simulate_api_call(url, method="GET", headers=None, timeout=None, data=None):
    """Simulate API responses for different endpoints."""
    # Simulated responses based on URL
    if "prometheus" in url:
        return MockResponse(200, {"status": "success", "data": {"resultType": "vector", "result": [
            {"metric": {"instance": "web-01:9090"}, "value": [time.time(), "0.95"]},
            {"metric": {"instance": "api-01:9090"}, "value": [time.time(), "0.72"]},
        ]}})
    elif "github" in url:
        if headers and "Authorization" in headers:
            return MockResponse(200, [
                {"name": "main", "commit": {"sha": "abc123"}},
                {"name": "develop", "commit": {"sha": "def456"}},
            ])
        else:
            return MockResponse(401, {"message": "Bad credentials"})
    elif "kubernetes" in url:
        return MockResponse(200, '{"major": "1", "minor": "28"}')  # String body!
    elif "timeout" in url:
        time.sleep(0.1)
        if timeout and timeout < 0.05:
            raise TimeoutError(f"Request to {url} timed out after {timeout}s")
        return MockResponse(200, {"status": "ok"})
    elif "broken" in url:
        return MockResponse(200, "This is not JSON at all<html>error</html>")
    else:
        return MockResponse(404, {"error": "Not Found"})


def get_prometheus_metrics(base_url):
    """Fetch CPU usage metrics from Prometheus."""
    url = f"{base_url}/api/v1/query?query=cpu_usage"
    
    # BUG 1: No timeout specified — could hang forever in real scenario
    # Also: not checking status code before parsing
    response = simulate_api_call(url)
    
    # This works for our simulation, but demonstrates the pattern
    data = response.json()
    metrics = []
    for result in data["data"]["result"]:
        metrics.append({
            "instance": result["metric"]["instance"],
            "cpu_usage": float(result["value"][1])
        })
    return metrics


def get_github_branches(repo, token):
    """Get branches from GitHub API."""
    url = f"https://api.github.com/repos/{repo}/branches"
    
    # BUG 2: Auth header format is wrong — GitHub expects "token XXX" or "Bearer XXX"
    headers = {
        "Authorization": token,  # Should be f"token {token}" or f"Bearer {token}"
        "Accept": "application/vnd.github.v3+json"
    }
    
    response = simulate_api_call(url, headers=headers)
    
    # BUG 3: Not checking response status code — 401 means auth failed
    # Calling .json() on error response gives unhelpful data
    branches = response.json()
    return branches


def get_k8s_version(api_server):
    """Get Kubernetes cluster version."""
    url = f"{api_server}/version"
    response = simulate_api_call(url + "?kubernetes=true")
    
    # Response body is a JSON string, not pre-parsed dict
    version_info = response.json()
    
    # This should work if json() returns a dict
    if isinstance(version_info, dict):
        return f"{version_info.get('major', '?')}.{version_info.get('minor', '?')}"
    return "unknown"


def check_endpoint_with_timeout(url, timeout=5):
    """Check an endpoint with a timeout."""
    try:
        response = simulate_api_call(url + "?timeout=true", timeout=timeout)
        return {"url": url, "status": "reachable", "code": response.status_code}
    except TimeoutError as e:
        return {"url": url, "status": "timeout", "error": str(e)}


def main():
    print("=" * 55)
    print("  DevOps API Status Dashboard")
    print("=" * 55)
    
    # 1. Prometheus metrics
    print("\n📊 Prometheus Metrics:")
    try:
        metrics = get_prometheus_metrics("http://prometheus.internal:9090")
        for m in metrics:
            bar = "█" * int(m["cpu_usage"] * 20)
            print(f"  {m['instance']}: {m['cpu_usage']:.0%} {bar}")
    except Exception as e:
        print(f"  ❌ Failed: {e}")
    
    # 2. GitHub branches
    print("\n🐙 GitHub Branches (myorg/myapp):")
    try:
        branches = get_github_branches("myorg/myapp", "ghp_fake_token_12345")
        if isinstance(branches, list):
            for b in branches:
                print(f"  🌿 {b['name']} → {b['commit']['sha'][:7]}")
        elif isinstance(branches, dict) and "message" in branches:
            print(f"  ❌ API Error: {branches['message']}")
    except Exception as e:
        print(f"  ❌ Failed: {e}")
    
    # 3. K8s version
    print("\n☸️  Kubernetes Version:")
    try:
        version = get_k8s_version("https://k8s-api.internal:6443")
        print(f"  Cluster version: {version}")
    except Exception as e:
        print(f"  ❌ Failed: {e}")
    
    # 4. Endpoint checks
    print("\n🔍 Endpoint Reachability:")
    endpoints = [
        "http://web-app.internal:8080",
        "http://slow-service.internal:3000",
    ]
    for url in endpoints:
        result = check_endpoint_with_timeout(url, timeout=0.01)
        icon = "✅" if result["status"] == "reachable" else "⏱️ "
        print(f"  {icon} {result['url']}: {result['status']}")
    
    print("\n" + "=" * 55)


if __name__ == "__main__":
    main()
