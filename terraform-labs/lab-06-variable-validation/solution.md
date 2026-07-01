## Solution: Variable Validation Failures

### Root Cause

The `terraform.tfvars` file contains values that violate every variable validation rule defined in `variables.tf`:

1. `environment = "prod"` — must be `dev`, `staging`, or `production`
2. `project_name = "My_Project"` — must be lowercase, start with a letter, alphanumeric+hyphens, 3-20 chars
3. `instance_type = "c5.xlarge"` — must start with `t3.` or `m5.`
4. `vpc_cidr = 10` — must be a valid CIDR string like `10.0.0.0/16`
5. `allowed_ports = [80, 443, 0, 99999]` — ports must be 1-65535
6. `instance_count = 15` — must be between 1 and 10
7. `tags` — missing required `Owner` key

### Step-by-Step Fix

```bash
# 1. Fix all values in terraform.tfvars (see below)
# 2. Validate
terraform validate
# 3. Plan
terraform plan
```

### Fixed Code (terraform.tfvars)

```hcl
# Fix 1: Use full name "production" not "prod"
environment = "production"

# Fix 2: Lowercase, no underscores, starts with letter
project_name = "my-project"

# Fix 3: Must be t3 or m5 family
instance_type = "t3.xlarge"

# Fix 4: Must be a valid CIDR string
vpc_cidr = "10.0.0.0/16"

# Fix 5: All ports must be 1-65535 (removed 0 and 99999)
allowed_ports = [80, 443, 8080, 8443]

# Fix 6: Must be between 1 and 10
instance_count = 3

# Fix 7: Must include "Owner" key
tags = {
  Team        = "platform"
  Environment = "production"
  Owner       = "platform-team"
}
```

### Verification

```bash
# Should pass with no errors
terraform validate

# Plan should succeed
terraform plan

# If you want to test individual variable validation:
terraform plan -var='environment=invalid'
# Expected: "The environment must be one of: dev, staging, production."
```
