## Solution: CRD Validation Failure

### Root Cause

The CRD schema has multiple bugs causing CR instances to fail validation:
1. `engine` field: type is `integer` but enum values are strings — should be `type: string`
2. `replicas` field: type is `string` but values are integers — should be `type: integer`
3. Required field mismatch: CRD requires `storageclass` (lowercase) but CRs use `storageClass`
4. `backup.schedule` pattern is too strict — doesn't match human values like "daily"
5. CR uses `engine: "postgres"` but enum only allows `"postgresql"`
6. `dev-analytics-db` has `storageSize: "500MB"` which doesn't match pattern `^[0-9]+(Gi|Ti|Mi)$`

### Diagnosis

```bash
kubectl apply -f broken-deployment.yaml -n lab-19-crd
# Shows validation errors
kubectl get crd databaseclusters.platform.example.com -o yaml
```

### Fix

Fix the CRD schema:

```bash
kubectl apply -f - <<EOF
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databaseclusters.platform.example.com
spec:
  group: platform.example.com
  names:
    kind: DatabaseCluster
    listKind: DatabaseClusterList
    plural: databaseclusters
    singular: databasecluster
    shortNames: ["dbc"]
  scope: Namespaced
  versions:
    - name: v1alpha1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required: ["engine", "storageClass", "replicas"]
              properties:
                engine:
                  type: string
                  enum: ["postgresql", "postgres", "mysql", "mariadb"]
                replicas:
                  type: integer
                  minimum: 1
                  maximum: 7
                version:
                  type: string
                storageClass:
                  type: string
                storageSize:
                  type: string
                  pattern: '^[0-9]+(Gi|Ti|Mi)$'
                backup:
                  type: object
                  properties:
                    enabled:
                      type: boolean
                    schedule:
                      type: string
                    retention:
                      type: string
                  required: ["enabled"]
                highAvailability:
                  type: object
                  properties:
                    enabled:
                      type: boolean
                    syncMode:
                      type: string
                      enum: ["sync", "async", "semi-sync"]
            status:
              type: object
              properties:
                phase:
                  type: string
                readyReplicas:
                  type: integer
EOF
```

Then fix the CR instances (fix `storageSize` on dev-analytics-db):

```bash
kubectl apply -f - <<EOF
apiVersion: platform.example.com/v1alpha1
kind: DatabaseCluster
metadata:
  name: dev-analytics-db
  namespace: lab-19-crd
spec:
  engine: "mysql"
  replicas: 1
  version: "8.0"
  storageClass: "standard"
  storageSize: "500Mi"
  backup:
    enabled: false
    schedule: "0 0 * * *"
EOF
```

### Verification

```bash
kubectl get databaseclusters -n lab-19-crd
# All three CR instances should be listed
kubectl describe databasecluster production-orders-db -n lab-19-crd
```
