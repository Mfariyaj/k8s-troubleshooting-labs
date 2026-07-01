## Solution: Moved Blocks and State Refactoring

### Root Cause

All `moved` blocks have incorrect `from` and/or `to` addresses that don't match the actual state paths:

1. **Instances**: `from = module.legacy.aws_instance.web[0]` — but state has `aws_instance.web[0]` (root level, no module prefix)
2. **Instances `to`**: Uses `"0"` as key but module uses `"web-0"`
3. **S3 buckets**: `from = module.storage_legacy.aws_s3_bucket.data[0]` — but state has `aws_s3_bucket.data[0]`
4. **S3 `to`**: Missing for_each key; both point to same address
5. **RDS**: `from = module.databases.module.primary.aws_rds_cluster.main` — but state has `aws_rds_cluster.main`
6. **IAM roles `to`**: Uses count index `[0]` but module uses for_each keys
7. **Module source path**: `./modules/refactored/servers` doesn't exist (should be `./modules/refactored/compute`)

### Step-by-Step Fix

```bash
# 1. Check current state addresses
terraform state list

# 2. Fix all moved blocks to match actual state paths (see below)

# 3. Fix module source path
# 4. Validate and plan
terraform validate
terraform plan
# Should show moves, NOT destroy/create
```

### Fixed Code (main.tf — moved blocks)

```hcl
# Fix: 'from' at root level (no module prefix), 'to' uses correct for_each keys
moved {
  from = aws_instance.web[0]
  to   = module.compute.aws_instance.web["web-0"]
}

moved {
  from = aws_instance.web[1]
  to   = module.compute.aws_instance.web["web-1"]
}

moved {
  from = aws_instance.web[2]
  to   = module.compute.aws_instance.web["web-2"]
}

# Fix: S3 buckets from root level, with correct for_each keys
moved {
  from = aws_s3_bucket.data[0]
  to   = module.storage.aws_s3_bucket.data["bucket-0"]
}

moved {
  from = aws_s3_bucket.data[1]
  to   = module.storage.aws_s3_bucket.data["bucket-1"]
}

# Fix: RDS from root level
moved {
  from = aws_rds_cluster.main
  to   = module.database.aws_rds_cluster.main
}

# Fix: IAM roles — from count to for_each keys
moved {
  from = aws_iam_role.service[0]
  to   = module.iam.aws_iam_role.service["api-service"]
}

moved {
  from = aws_iam_role.service[1]
  to   = module.iam.aws_iam_role.service["worker-service"]
}
```

### Fixed Code (module source path)

```hcl
module "compute" {
  source = "./modules/refactored/compute"  # Fix: correct directory name
  # ...
}
```

### Verification

```bash
terraform validate
terraform plan
# Expected output should show:
#   ~ moved aws_instance.web[0] -> module.compute.aws_instance.web["web-0"]
#   ~ moved aws_instance.web[1] -> module.compute.aws_instance.web["web-1"]
# NO destroy/create actions

terraform apply
terraform state list
# Confirm resources are now at their new addresses
```
