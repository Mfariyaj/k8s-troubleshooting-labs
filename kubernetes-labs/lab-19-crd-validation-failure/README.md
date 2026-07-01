# Lab 19: CRD Validation Failure

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your platform engineering team maintains a custom Kubernetes operator for managing
database provisioning. The CRD `DatabaseCluster` defines the schema for provisioning
PostgreSQL and MySQL clusters. After a schema update in the latest release, ALL new
DatabaseCluster custom resources fail validation with cryptic OpenAPI errors. The CI/CD
pipeline that provisions databases for new microservices is completely broken. Teams are
unable to create new database instances for their services.

## Symptoms

```bash
$ kubectl apply -f broken-deployment.yaml
customresourcedefinition.apiextensions.k8s.io/databaseclusters.platform.example.com created
Error from server (Invalid): error when creating "broken-deployment.yaml": DatabaseCluster.platform.example.com "production-orders-db" is invalid:
* spec.engine: Invalid value: "integer": spec.engine in body must be of type string: "integer"
* spec.replicas: Invalid value: "string": spec.replicas in body must be of type integer: "string"
* spec.storageClass: Required value
* spec.backup.schedule: Invalid value: "daily": spec.backup.schedule in body should match '^(\d+|\*)(/\d+)?(\s+(\d+|\*)(/\d+)?){4}$'
* spec.engine: Unsupported value: "postgres": supported values: "postgresql", "mysql", "mariadb"
```

## Error Output

```bash
$ kubectl get databaseclusters -n lab-19-crd
No resources found in lab-19-crd namespace.

$ kubectl explain databasecluster.spec
KIND:     DatabaseCluster
VERSION:  platform.example.com/v1alpha1

FIELD:    spec <Object>
DESCRIPTION: DatabaseCluster specification

FIELDS:
  engine       <string> -required-  (enum: postgresql, mysql, mariadb)
  replicas     <string>             (NOTE: This is wrong — should be integer)
  version      <string>
  storageClass <string> -required-
  backup       <Object>
  ...

$ kubectl get crd databaseclusters.platform.example.com -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.engine}' | jq .
{
  "type": "integer",
  "enum": ["postgresql", "mysql", "mariadb"]
}
```

## Hints

<details>
<summary>Hint 1 (Conceptual)</summary>
CRD OpenAPI v3 validation is strict. If a field's `type` doesn't match the actual value being submitted, or if `enum` values don't match what users are providing, the API server rejects the CR immediately. Check the CRD schema types carefully against what the CR instances provide.
</details>

<details>
<summary>Hint 2 (Direction)</summary>
Multiple schema issues: (1) `spec.engine` has `type: integer` but should be `type: string` — enum values are strings. (2) `spec.replicas` has `type: string` but should be `type: integer`. (3) `spec.storageClass` is in `required` list but the CR doesn't provide it (actually the CR does but the field name in the schema is `storageclass` — case mismatch). (4) `spec.backup.schedule` has a cron regex pattern but the CR uses "daily" instead of a cron expression. (5) The enum uses "postgresql" but the CR submits "postgres".
</details>

<details>
<summary>Hint 3 (Solution Path)</summary>
Fix the CRD schema: (1) Change `spec.engine.type` from `integer` to `string`. (2) Change `spec.replicas.type` from `string` to `integer`. (3) Fix the `storageClass` field name casing in the schema (use camelCase consistently). (4) Either add "postgres" to the enum or change the CR to use "postgresql". (5) Fix the backup schedule to use a valid cron expression like "0 2 * * *" in the CR, or relax the pattern in the CRD. Re-apply the CRD then re-apply the CRs.
</details>

## Troubleshooting Commands

```bash
# Check if the CRD was created successfully
kubectl get crd databaseclusters.platform.example.com

# View the full CRD schema
kubectl get crd databaseclusters.platform.example.com -o yaml

# Check the schema for specific fields
kubectl get crd databaseclusters.platform.example.com -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties}' | jq .

# Try applying just the CRD
kubectl apply -f broken-deployment.yaml --dry-run=server 2>&1 | head -20

# Check what types are defined for each field
kubectl get crd databaseclusters.platform.example.com -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.engine}' | jq .
kubectl get crd databaseclusters.platform.example.com -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.replicas}' | jq .

# Check required fields in the CRD
kubectl get crd databaseclusters.platform.example.com -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.required}' | jq .

# Use kubectl explain to understand the schema
kubectl explain databasecluster.spec
kubectl explain databasecluster.spec.engine
kubectl explain databasecluster.spec.backup

# Try dry-run to see validation errors without applying
kubectl apply -f broken-deployment.yaml --dry-run=server 2>&1

# Check events for CRD-related issues
kubectl get events -n lab-19-crd

# List all CRDs to verify naming
kubectl get crd | grep database
```

## Expected Resolution Time: 15-25 minutes

## What You'll Learn

- How CRD OpenAPI v3 validation works
- Common schema definition mistakes (type mismatches, enum errors)
- How to debug CRD validation errors from cryptic API server messages
- The importance of schema versioning in CRDs
- How field naming conventions (camelCase vs lowercase) affect validation
- Using `kubectl explain` and JSONPath to inspect CRD schemas
