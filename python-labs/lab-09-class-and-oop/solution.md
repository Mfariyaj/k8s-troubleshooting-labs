# Solution: Lab 09 — Class and OOP

## Root Cause

### Bug 1: Missing `self` in Server.__init__()
```python
# BROKEN: First positional arg becomes self, so hostname is bound as self
def __init__(hostname, ip_address, cpu_cores, ram_gb):

# FIXED: self must be first parameter
def __init__(self, hostname, ip_address, cpu_cores, ram_gb):
```

### Bug 2: WebServer doesn't call parent __init__()
```python
# BROKEN: Parent attributes (hostname, ip_address, etc.) never created
def __init__(self, hostname, ip_address, cpu_cores, ram_gb, port=80, max_connections=1000):
    self.port = port

# FIXED: Call parent first
def __init__(self, hostname, ip_address, cpu_cores, ram_gb, port=80, max_connections=1000):
    super().__init__(hostname, ip_address, cpu_cores, ram_gb)
    self.port = port
    self.max_connections = max_connections
    self.active_connections = 0
```

### Bug 3: Calling @property with parentheses
```python
# BROKEN: Property is not callable
print(f"... Uptime: {server.uptime()}h")

# FIXED: Access property without ()
print(f"... Uptime: {server.uptime}h")
```

---

## Key Takeaways

1. **`self` is always the first method parameter** — Python passes the instance automatically
2. **Always call `super().__init__()`** in subclasses — parent won't initialize itself
3. **`@property` creates an attribute-like accessor** — access with `.prop` not `.prop()`
4. **Inheritance requires explicit parent setup** — Python doesn't auto-call parent constructors
5. **Use `super()`** not `ParentClass.__init__(self, ...)` — it handles MRO correctly
