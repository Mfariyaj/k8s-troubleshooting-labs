#!/usr/bin/env python3
"""
Server Cost Calculator
======================
This script calculates the monthly cost of running servers
based on instance type, count, and hours of usage.

INTENDED BEHAVIOR:
- Read server inventory with instance counts and hourly costs
- Calculate total monthly cost per server group
- Print a formatted cost report
"""

import sys

# Server pricing (hourly rate in USD)
PRICING = {
    "t3.micro": 0.0104,
    "t3.medium": 0.0416,
    "m5.large": 0.096,
    "m5.xlarge": 0.192,
    "c5.2xlarge": 0.34,
}

HOURS_PER_MONTH = 730

def calculate_monthly_cost(instance_type, count, discount_percent):
    """Calculate monthly cost for a group of servers."""
    # BUG 1: count comes in as a string from the inventory, causes TypeError
    hourly_rate = PRICING[instance_type]
    monthly_cost = hourly_rate * count * HOURS_PER_MONTH
    
    # BUG 2: discount_percent is a string like "10", arithmetic fails
    discount = monthly_cost * (discount_percent / 100)
    final_cost = monthly_cost - discount
    
    return final_cost


def format_report_line(service_name, instance_type, count, cost):
    """Format a single line of the cost report."""
    # BUG 3: Trying to concatenate string with float using +
    return "  " + service_name + " | " + instance_type + " | " + count + " instances | $" + cost + "/month"


def generate_cost_report(inventory):
    """Generate a full cost report from server inventory."""
    print("=" * 60)
    print("  Monthly Cloud Cost Report")
    print("=" * 60)
    
    total_cost = 0
    
    for service in inventory:
        service_name = service["name"]
        instance_type = service["instance_type"]
        count = service["count"]
        discount = service["discount"]
        
        cost = calculate_monthly_cost(instance_type, count, discount)
        total_cost += cost
        
        report_line = format_report_line(service_name, instance_type, count, cost)
        print(report_line)
    
    print("=" * 60)
    print(f"  Total Monthly Cost: ${total_cost:.2f}")
    print("=" * 60)


def main():
    # Server inventory — note: count and discount are strings (as if read from CSV)
    inventory = [
        {"name": "Web Tier", "instance_type": "t3.medium", "count": "10", "discount": "0"},
        {"name": "API Servers", "instance_type": "m5.large", "count": "5", "discount": "15"},
        {"name": "Workers", "instance_type": "c5.2xlarge", "count": "3", "discount": "10"},
        {"name": "Monitoring", "instance_type": "t3.micro", "count": "2", "discount": "0"},
        {"name": "Database", "instance_type": "m5.xlarge", "count": "2", "discount": "20"},
    ]
    
    print("Calculating server costs...")
    print("")
    generate_cost_report(inventory)


if __name__ == "__main__":
    main()
