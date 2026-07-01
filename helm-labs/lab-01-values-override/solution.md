# Lab 01 - Values Override Precedence

## Root Cause

Helm's `--set` flag always overrides values from `-f` (values files). When using both
in the same command, `--set` takes precedence regardless of argument order. Complex nested
values set via `--set` use dot notation which can be error-prone.

The deploy script uses `--set` for values that conflict with the values file, causing
unexpected configuration.

## Symptoms

- Deployed resources have unexpected values despite correct values file
- Complex values (arrays, nested objects) are malformed when set via `--set`
- Helm output shows values different from what the values file specifies

## Fix Steps

1. Understand that `--set` always overrides `-f` values files
2. For complex values (arrays, maps), use `-f` with a values file instead of `--set`
3. If multiple `-f` flags are used, the last file wins for conflicting keys

## Corrected Approach

Instead of:
```bash
# BROKEN: --set overrides the values file
helm install myapp ./mychart \
  -f custom-values.yaml \
  --set image.tag=latest
```

Use a values file for all complex configuration:
```bash
# CORRECT: Use -f for complex values, --set only for simple overrides
helm install myapp ./mychart -f custom-values.yaml
```

Or if you need multiple overrides, layer values files:
```bash
helm install myapp ./mychart \
  -f values-base.yaml \
  -f values-env.yaml
```

## Verification

```bash
# Check what values Helm will use (dry-run)
helm template myapp ./mychart -f custom-values.yaml

# Install and verify
helm install myapp ./mychart -f custom-values.yaml

# Confirm deployed values
helm get values myapp
```

## Key Takeaways

- `--set` always overrides `-f` values files (highest precedence)
- Multiple `-f` files: last one wins for conflicts
- Use `-f` for complex values (arrays, nested maps)
- Use `helm template` or `--dry-run` to preview merged values
