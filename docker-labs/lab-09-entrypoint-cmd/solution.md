## Solution: Entrypoint CMD Interaction

### Root Cause

The ENTRYPOINT is in **shell form** (`ENTRYPOINT python tool.py`), which Docker executes as `/bin/sh -c "python tool.py"`. In shell form, CMD arguments are completely ignored — they are never appended. The intended `CMD ["process", "--all"]` arguments are silently dropped.

### Step-by-Step Fix

1. Change ENTRYPOINT from shell form to exec form (JSON array)
2. Use `ENTRYPOINT ["python", "tool.py"]`
3. CMD arguments will now be appended correctly

### Fixed Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY tool.py ./

# Exec form — CMD args are appended as arguments to tool.py
ENTRYPOINT ["python", "tool.py"]

# These arguments are now correctly passed to tool.py
CMD ["process", "--all"]
```

### How It Works

| Form | Docker executes | CMD appended? |
|------|----------------|---------------|
| Shell: `ENTRYPOINT python tool.py` | `/bin/sh -c "python tool.py"` | No |
| Exec: `ENTRYPOINT ["python", "tool.py"]` | `python tool.py <CMD args>` | Yes |

### Verification

```bash
docker build -t lab09-fixed .

# Run with default CMD args
docker run --rm lab09-fixed
# Should execute: python tool.py process --all

# Override CMD at runtime
docker run --rm lab09-fixed export --format=json
# Should execute: python tool.py export --format=json

docker run --rm lab09-fixed --help
# Should show tool.py help
```
