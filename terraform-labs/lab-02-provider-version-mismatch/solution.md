## Solution: Provider Version Mismatch

### Root Cause

The `versions.tf` file pins the AWS provider to exactly `= 4.67.0`, but the `.terraform.lock.hcl` file records version `5.31.0`. When running `terraform init`, Terraform detects the conflict between the constraint and the lock file, refusing to proceed:

```
Error: Failed to query available provider packages
Could not retrieve the list of available versions for provider hashicorp/aws:
locked provider registry.terraform.io/hashicorp/aws 5.31.0 does not match configured version constraint = 4.67.0
```

### Step-by-Step Fix

**Option A: Update the version constraint to match what you actually want (recommended):**

```bash
# Edit versions.tf to allow the newer provider version
# Then update the lock file
terraform init -upgrade
```

**Option B: Force downgrade to match the constraint:**

```bash
# Delete the lock file and reinitialize
rm .terraform.lock.hcl
terraform init
```

### Fixed Code (versions.tf)

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### Verification

```bash
# Reinitialize with corrected constraint
terraform init -upgrade

# Confirm provider version
terraform version

# Verify plan works
terraform plan

# Check lock file reflects correct version
cat .terraform.lock.hcl | grep -A2 "provider"
```

### Key Takeaway

- `= 4.67.0` means exactly that version — no flexibility
- `~> 5.0` allows `5.x` minor/patch upgrades
- Always commit `.terraform.lock.hcl` and run `terraform init -upgrade` when intentionally bumping providers
