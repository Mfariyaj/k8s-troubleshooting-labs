# Solution: Lab 02 — Type Errors

## Root Cause

The script reads server inventory data where numeric values are stored as strings (simulating data from CSV/API). Python's strong typing raises `TypeError` when you try arithmetic with strings or concatenate strings with numbers.

### Bug 1: String multiplication (Line 31)
```python
# BROKEN: count is "10" (string), can't multiply float * string
monthly_cost = hourly_rate * count * HOURS_PER_MONTH

# FIXED: Convert to int first
monthly_cost = hourly_rate * int(count) * HOURS_PER_MONTH
```

### Bug 2: String division (Line 34)
```python
# BROKEN: discount_percent is "10" (string), can't divide string by int
discount = monthly_cost * (discount_percent / 100)

# FIXED: Convert to float
discount = monthly_cost * (float(discount_percent) / 100)
```

### Bug 3: String concatenation with non-strings (Line 42)
```python
# BROKEN: Can't use + to join str with int and float
return "  " + service_name + " | " + instance_type + " | " + count + " instances | $" + cost + "/month"

# FIXED: Use f-string (cleanest approach)
return f"  {service_name} | {instance_type} | {count} instances | ${cost:.2f}/month"
```

---

## Fixed Code

```python
def calculate_monthly_cost(instance_type, count, discount_percent):
    hourly_rate = PRICING[instance_type]
    monthly_cost = hourly_rate * int(count) * HOURS_PER_MONTH
    discount = monthly_cost * (float(discount_percent) / 100)
    final_cost = monthly_cost - discount
    return final_cost


def format_report_line(service_name, instance_type, count, cost):
    return f"  {service_name} | {instance_type} | {count} instances | ${cost:.2f}/month"
```

---

## Verification

```bash
$ python3 broken_script.py
Calculating server costs...

============================================================
  Monthly Cloud Cost Report
============================================================
  Web Tier | t3.medium | 10 instances | $303.68/month
  API Servers | m5.large | 5 instances | $297.84/month
  Workers | c5.2xlarge | 3 instances | $669.06/month
  Monitoring | t3.micro | 2 instances | $15.18/month
  Database | m5.xlarge | 2 instances | $224.26/month
============================================================
  Total Monthly Cost: $1510.02
============================================================
```

---

## Key Takeaways

1. **Python is strongly typed** — it never silently converts types
2. **Data from external sources is always strings** — CSV, env vars, command line args, API responses (before JSON parsing)
3. **Use `int()`, `float()`, `str()`** for explicit conversion
4. **f-strings are preferred** — they handle type conversion automatically in string formatting
5. **Use `type(x)` to debug** — when you get TypeError, print the type of each variable
