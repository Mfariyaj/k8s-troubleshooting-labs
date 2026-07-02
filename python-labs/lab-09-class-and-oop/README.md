# Lab 09: Classes & OOP — self, __init__, super(), @property

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-09/broken_script.py
cd /tmp/python-lab-09 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Object-Oriented Programming in Python**

Classes are essential for modeling complex systems — a server fleet, a CI/CD pipeline, an infrastructure stack. Key concepts:

- **`self`** — the first parameter of every method, refers to the instance. Forgetting it means the first real argument becomes `self`, and everything shifts.
- **`__init__`** — the constructor. Every class should initialize its own attributes here.
- **`super().__init__()`** — calls the parent class's constructor. Without it, inherited attributes aren't created.
- **`@property`** — makes a method accessible as an attribute (no parentheses). Calling a property with `()` raises `TypeError`.
- **Inheritance** — subclasses inherit all methods from parents, but must call `super().__init__()` to set up parent state.

Method Resolution Order (MRO): Python checks the current class first, then parent classes left-to-right when calling methods.

---

## 🔧 Scenario

A server infrastructure manager with a class hierarchy: `Server` → `WebServer`, `DatabaseServer`. A `ServerFleet` class manages collections of servers. The script creates servers, starts them, simulates traffic, and generates a fleet status report.

---

## 💥 Error Output

```
Traceback (most recent call last):
  File "broken_script.py", line 135, in <module>
    main()
  File "broken_script.py", line 115, in main
    web1 = WebServer("web-prod-01", "10.0.1.10", 4, 16, port=8080)
  File "broken_script.py", line 56, in __init__
    self.port = port
  ...
AttributeError: 'WebServer' object has no attribute 'hostname'
```

Or, depending on Python version:
```
TypeError: __init__() takes 4 positional arguments but 5 were given
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

Look at the base `Server.__init__()` method carefully. Count the parameters. Then look at how `WebServer.__init__()` sets up the parent.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three bugs:
1. `Server.__init__()` is missing `self` as its first parameter — Python will bind `hostname` as `self`
2. `WebServer.__init__()` doesn't call `super().__init__(hostname, ip_address, cpu_cores, ram_gb)` — so parent attributes never get created
3. In `ServerFleet.get_fleet_report()`, `server.uptime()` calls the `@property` with parentheses — but properties are accessed without `()`
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Add `self` as first parameter: `def __init__(self, hostname, ip_address, cpu_cores, ram_gb):`
2. In WebServer.__init__, add: `super().__init__(hostname, ip_address, cpu_cores, ram_gb)` before setting port
3. Change `server.uptime()` to `server.uptime` (no parentheses — it's a property)
</details>

---

## 📖 Python Docs Reference

- [Classes Tutorial](https://docs.python.org/3/tutorial/classes.html)
- [super()](https://docs.python.org/3/library/functions.html#super)
- [@property decorator](https://docs.python.org/3/library/functions.html#property)
- [Method Resolution Order](https://docs.python.org/3/tutorial/classes.html#multiple-inheritance)

---

## Difficulty: ⭐⭐⭐ Advanced

**Expected time:** 7-10 minutes  
**Bugs to find:** 3  
**Concept:** OOP fundamentals — self, inheritance, properties
