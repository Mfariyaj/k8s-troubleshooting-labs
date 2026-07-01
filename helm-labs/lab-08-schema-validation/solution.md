# Lab 08 - Schema Validation Failures

## Root Cause

The `values.schema.json` file has two restrictive issues:
1. An `enum` constraint is too narrow - it does not include all valid values needed
2. The `image.tag` property type is set to `integer` or `number` when it should be `string`
   (tags like "v1.2.3" or "latest" are strings)

## Symptoms

- `helm install` fails with JSON schema validation errors
- Error messages like "image.tag: Invalid type. Expected: integer, Given: string"
- Valid values rejected because they are not in the enum list
- `helm lint` reports schema violations

## Fix Steps

1. Open `mychart/values.schema.json`
2. Expand the enum to include additional valid values
3. Change `image.tag` type from `integer`/`number` to `string`

## Corrected Configuration

```json
{
  "$schema": "https://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "image": {
      "type": "object",
      "properties": {
        "repository": {
          "type": "string"
        },
        "tag": {
          "type": "string"
        },
        "pullPolicy": {
          "type": "string",
          "enum": ["Always", "IfNotPresent", "Never"]
        }
      }
    },
    "replicaCount": {
      "type": "integer",
      "minimum": 1
    },
    "service": {
      "type": "object",
      "properties": {
        "type": {
          "type": "string",
          "enum": ["ClusterIP", "NodePort", "LoadBalancer", "ExternalName"]
        }
      }
    }
  }
}
```

## Verification

```bash
# Lint with schema validation
helm lint ./mychart

# Install with string tag value
helm install myapp ./mychart --set image.tag=v1.2.3

# Verify schema allows valid values
helm template myapp ./mychart --set service.type=NodePort
```

## Key Takeaways

- Image tags are always strings in Kubernetes (even "123" is a string)
- Enum lists must cover all valid values users may need
- Test schema with `helm lint` and various value combinations
- Use `--set-string` to force string type when using `--set`
