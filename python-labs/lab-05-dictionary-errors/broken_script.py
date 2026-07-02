#!/usr/bin/env python3
"""
Kubernetes Pod Status Parser
==============================
This script reads a K8s pod list JSON and displays status info.

INTENDED BEHAVIOR:
- Read pod JSON from file
- Extract pod name, namespace, status, node, restart count
- Display a formatted status report
"""

import json
import os


def load_pod_data(filepath):
    """Load Kubernetes pod data from JSON file."""
    with open(filepath, 'r') as f:
        data = json.loads(f)  # BUG 1: json.loads() is for strings, json.load() is for files
    return data


def get_pod_summary(pod):
    """Extract summary info from a single pod."""
    # BUG 2: Using direct key access without .get() — some pods don't have 'tier' label
    name = pod["metadata"]["name"]
    namespace = pod["metadata"]["namespace"]
    tier = pod["metadata"]["labels"]["tier"]  # Not all pods have this label!
    
    # Get container info
    container = pod["spec"]["containers"][0]
    image = container["image"]
    
    # Get status
    phase = pod["status"]["phase"]
    container_status = pod["status"]["containerStatuses"][0]
    restart_count = container_status["restartCount"]
    
    # BUG 3: Accessing nested key that varies based on state (running vs waiting)
    # Not all pods have "running" state — some are in "waiting" state
    start_time = container_status["state"]["running"]["startedAt"]
    
    return {
        "name": name,
        "namespace": namespace,
        "tier": tier,
        "image": image,
        "phase": phase,
        "restarts": restart_count,
        "start_time": start_time
    }


def display_pod_report(pods_data):
    """Display formatted pod status report."""
    print("=" * 70)
    print("  Kubernetes Pod Status Report")
    print("=" * 70)
    
    pods = pods_data["items"]
    
    for pod in pods:
        summary = get_pod_summary(pod)
        
        status_icon = "✅" if summary["phase"] == "Running" else "❌"
        
        print(f"\n  {status_icon} Pod: {summary['name']}")
        print(f"     Namespace: {summary['namespace']}")
        print(f"     Tier:      {summary['tier']}")
        print(f"     Image:     {summary['image']}")
        print(f"     Status:    {summary['phase']}")
        print(f"     Restarts:  {summary['restarts']}")
        print(f"     Started:   {summary['start_time']}")
    
    print("\n" + "=" * 70)
    total = len(pods)
    running = sum(1 for p in pods if p["status"]["phase"] == "Running")
    print(f"  Summary: {running}/{total} pods running")
    print("=" * 70)


def main():
    data_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sample_data.json")
    
    print("Loading Kubernetes pod data...")
    pod_data = load_pod_data(data_file)
    
    print(f"Found {len(pod_data['items'])} pods")
    display_pod_report(pod_data)


if __name__ == "__main__":
    main()
