#!/usr/bin/env python3
"""
Deployment Report Generator
=============================
This script generates formatted deployment reports with templates,
regex-based log parsing, and structured output.

INTENDED BEHAVIOR:
- Generate a deployment summary report
- Parse log lines with regex to extract timestamps and messages
- Format output using templates
"""

import re
from datetime import datetime


def generate_header(app_name, version, environment):
    """Generate a report header using .format() template."""
    # BUG 1: .format() template uses {environment} but we pass env= as keyword
    template = """
╔══════════════════════════════════════════════════╗
║  Deployment Report                               ║
║  App: {app_name}                                 ║
║  Version: {version}                              ║
║  Environment: {environment}                      ║
║  Date: {date}                                    ║
╚══════════════════════════════════════════════════╝
"""
    # BUG: keyword argument name doesn't match template placeholder
    return template.format(
        app_name=app_name,
        version=version,
        env=environment,  # Template says {environment} but we pass env=
        date=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    )


def parse_log_lines(log_text):
    """Parse log lines to extract timestamp, level, and message."""
    # BUG 2: Regex uses backslashes in a regular string — needs raw string
    # Pattern should match: [2024-01-15 10:30:00] ERROR: Something failed
    pattern = "[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}] (\w+): (.+)"
    
    results = []
    for line in log_text.strip().split('\n'):
        match = re.search(pattern, line)
        if match:
            results.append({
                "level": match.group(1),
                "message": match.group(2)
            })
    return results


def format_deployment_steps(steps):
    """Format deployment steps with status indicators."""
    output_lines = []
    
    for i, step in enumerate(steps, 1):
        # BUG 3: f-string has unescaped braces for dict access inside nested braces
        status_icon = "✅" if step["status"] == "success" else "❌"
        line = f"  {i}. {status_icon} {step['name']} — {step['duration']}s"
        output_lines.append(line)
    
    # This one has a subtle error: trying to use format() on a string that contains literal braces
    summary = "Deployment Summary: {total} steps, {passed} passed, {failed} failed"
    total = len(steps)
    passed = sum(1 for s in steps if s["status"] == "success")
    failed = total - passed
    
    # BUG 3: This will raise KeyError because the curly braces in the template 
    # conflict with JSON/dict representation in a format string
    details = "Results: {{passed: {0}, failed: {1}}}".format(passed, failed)
    output_lines.append("")
    output_lines.append(summary.format(total=total, passed=passed, failed=failed))
    output_lines.append(details)
    
    return "\n".join(output_lines)


def main():
    # Generate header
    print("Generating deployment report...\n")
    header = generate_header("payment-service", "v3.2.1", "production")
    print(header)
    
    # Parse deployment logs
    logs = """[2024-01-15 10:30:00] INFO: Starting deployment of payment-service v3.2.1
[2024-01-15 10:30:05] INFO: Pulling Docker image...
[2024-01-15 10:30:30] INFO: Image pulled successfully
[2024-01-15 10:30:31] ERROR: Health check failed on pod payment-service-abc123
[2024-01-15 10:30:45] INFO: Retry succeeded, pod is healthy
[2024-01-15 10:31:00] INFO: Deployment complete
"""
    
    print("📋 Log Analysis:")
    parsed = parse_log_lines(logs)
    for entry in parsed:
        level_icon = "🔴" if entry["level"] == "ERROR" else "🔵"
        print(f"  {level_icon} [{entry['level']}] {entry['message']}")
    
    if not parsed:
        print("  ⚠️  No log entries matched the pattern!")
    
    # Format deployment steps
    print("\n📊 Deployment Steps:")
    steps = [
        {"name": "Pull Image", "status": "success", "duration": 25},
        {"name": "Run Migrations", "status": "success", "duration": 10},
        {"name": "Health Check", "status": "failed", "duration": 30},
        {"name": "Rollback", "status": "success", "duration": 5},
    ]
    
    report = format_deployment_steps(steps)
    print(report)


if __name__ == "__main__":
    main()
