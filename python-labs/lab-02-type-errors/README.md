# Lab 02: Type Errors — Python Types & Type Conversion

## How to Use This Lab

```bash
./deploy.sh
# See the TypeError, then fix it
vim /tmp/python-lab-02/broken_script.py
cd /tmp/python-lab-02 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Python Type System & Type Conversion**

Python is a **dynamically typed** but **strongly typed** language. This means:
- You don't declare variable types (dynamic typing)
- But Python won't silently convert between types (strong typing)

For example, `"5" + 3` raises a `TypeError` — Python won't guess that you want `8` or `"53"`. You must explicitly convert: `int("5") + 3` → `8` or `"5" + str(3)` → `"53"`.

This is a common bug when reading data from files, APIs, or environment variables — everything comes in as strings and must be explicitly converted to numbers for math.

Key conversion functions: `int()`, `float()`, `str()`, `bool()`  
Modern alternative: f-strings handle conversion automatically: `f"Count: {count}"` works whether count is int or str.

---

## 🔧 Scenario

You have a script that calculates monthly cloud server costs. It reads a server inventory (simulating data from a CSV/API where values are strings) and computes costs with discounts. The script should produce a formatted cost report.

---

## 💥 Error Output

```
Calculating server costs...

Traceback (most recent call last):
  File "broken_script.py", line 82, in <module>
    main()
  File "broken_script.py", line 79, in main
    generate_cost_report(inventory)
  File "broken_script.py", line 58, in generate_cost_report
    cost = calculate_monthly_cost(instance_type, count, discount)
  File "broken_script.py", line 31, in calculate_monthly_cost
    monthly_cost = hourly_rate * count * HOURS_PER_MONTH
TypeError: can't multiply sequence by non-int of type 'float'
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

Look at what type `count` is when it enters `calculate_monthly_cost()`. It comes from the inventory dict where it's defined as a string `"10"`, not an integer `10`.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

There are 3 type-related bugs:
1. `count` is a string — you can't multiply a string by a float
2. `discount_percent` is also a string — you can't divide a string by an integer
3. `format_report_line()` uses `+` to concatenate strings with int and float values
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. In `calculate_monthly_cost()`: convert `count` with `int(count)` and `discount_percent` with `float(discount_percent)`
2. In `format_report_line()`: either use `str(count)` and `f"{cost:.2f}"`, or rewrite using an f-string: `f"  {service_name} | {instance_type} | {count} instances | ${cost:.2f}/month"`
</details>

---

## 📖 Python Docs Reference

- [Built-in Types](https://docs.python.org/3/library/stdtypes.html)
- [Built-in Functions (int, str, float)](https://docs.python.org/3/library/functions.html)
- [f-string Formatting](https://docs.python.org/3/reference/lexical_analysis.html#f-strings)
- [Type Errors](https://docs.python.org/3/library/exceptions.html#TypeError)

---

## Difficulty: ⭐ Beginner

**Expected time:** 3-5 minutes  
**Bugs to find:** 3  
**Concept:** Python's strong typing and explicit type conversion
