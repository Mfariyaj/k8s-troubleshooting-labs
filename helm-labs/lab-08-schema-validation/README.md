## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (runs helm template/install showing error)
2. Read the Helm error output carefully
3. Check Chart.yaml, values.yaml, and templates/ for issues
4. Fix the chart and re-run `helm template` or `helm install --dry-run`
5. Verify the rendered YAML is correct
6. Check `solution.md` if stuck

---

# Lab 08: Schema Validation Failures

## Difficulty: ⭐⭐ Medium

## Scenario

A developer added a `values.schema.json` to enforce value constraints on their Helm chart. However, the schema has two problems that reject valid configurations:

1. `replicaCount` has `"enum": [1, 3, 5]` — this rejects `replicaCount: 2`, which is a perfectly valid replica count
2. `image.tag` has `"type": "number"` — but image tags are strings (e.g., `"1.23"`, `"latest"`)

The values.yaml has `replicaCount: 2` and `image.tag: "1.23"`, both of which are rejected by the schema.

Your task: Fix the schema to accept valid values while still providing useful validation.

## Error Output

```
$ helm template myrelease ./mychart --debug
Error: values don't meet the specifications of the schema(s) in the following chart(s):
mychart:
- replicaCount: replicaCount must be one of the following: 1, 3, 5
- image.tag: Invalid type. Expected: number, Given: string

$ helm install myrelease ./mychart --dry-run
Error: values don't meet the specifications of the schema(s) in the following chart(s):
mychart:
- replicaCount: replicaCount must be one of the following: 1, 3, 5
- image.tag: Invalid type. Expected: number, Given: string
```

## Hints

1. The `enum` constraint on `replicaCount` is too restrictive — use `minimum: 1` and `maximum: 10` instead, or remove the enum entirely.
2. Image tags are always strings in Kubernetes (even if they look like numbers). Change the `type` from `"number"` to `"string"`.
3. JSON Schema validation happens before template rendering — the chart won't even start rendering if values fail schema validation.

## Commands

```bash
# Show the schema validation errors
helm template myrelease ./mychart --debug

# Show the schema file
cat mychart/values.schema.json

# After fixing, verify it passes
helm template myrelease ./mychart --debug
```

## Root Cause

Two issues in `values.schema.json`:
1. `replicaCount` uses `"enum": [1, 3, 5]` which rejects the valid value `2`
2. `image.tag` uses `"type": "number"` but image tags are strings (YAML `"1.23"` is a string)

## Fix

```json
{
  "replicaCount": {
    "type": "integer",
    "description": "Number of replicas",
    "minimum": 1,
    "maximum": 10
  },
  "image": {
    "properties": {
      "tag": {
        "type": "string",
        "description": "Container image tag"
      }
    }
  }
}
```
