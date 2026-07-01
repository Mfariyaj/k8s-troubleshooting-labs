## Solution: State Drift

### Root Cause

Someone manually modified the production RDS instance via the AWS Console, causing drift between Terraform state and actual infrastructure:

| Attribute | Terraform Code | Actual (AWS Console) |
|-----------|---------------|---------------------|
| `instance_class` | `db.t3.medium` | `db.r5.xlarge` |
| `multi_az` | `true` | `false` |
| `backup_retention_period` | `7` | `3` |

Running `terraform plan` shows Terraform wants to revert these changes, which could cause production outages.

### Step-by-Step Fix

**Option A: Accept real-world state (update code to match reality)**

```bash
# 1. Refresh state to detect current drift
terraform refresh

# 2. Run plan to see all drifted attributes
terraform plan

# 3. Update main.tf to match the actual production values (see below)

# 4. Verify plan shows no changes
terraform plan
# Expected: "No changes."
```

**Option B: Revert infrastructure to match code (risky in production)**

```bash
# WARNING: This will resize the RDS instance and cause downtime!
terraform apply
```

**Option C: Import fresh state for specific resources**

```bash
terraform state rm aws_db_instance.production
terraform import aws_db_instance.production prod-app-database
```

### Fixed Code (main.tf — accepting real-world state)

```hcl
resource "aws_db_instance" "production" {
  identifier     = "prod-app-database"
  engine         = "postgres"
  engine_version = "15.4"

  # Updated to match what was changed in AWS Console
  instance_class = "db.r5.xlarge"

  allocated_storage     = 100
  max_allocated_storage = 500
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "appdb"
  username = "admin"
  password = "PLACEHOLDER_CHANGE_ME"

  # Updated to match console change
  multi_az = false

  # Updated to match emergency change
  backup_retention_period = 3
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  vpc_security_group_ids = ["sg-0abc123def456"]
  db_subnet_group_name   = "prod-db-subnets"

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "prod-app-database-final"

  performance_insights_enabled = true

  tags = {
    Name        = "prod-app-database"
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "terraform"
  }
}
```

### Verification

```bash
terraform refresh
terraform plan
# Expected: "No changes. Your infrastructure matches the configuration."
```
