## Solution: Workspace Collision

### Root Cause

The S3 backend uses a **static key** (`applications/web-app/terraform.tfstate`) that doesn't include the workspace name. When using `terraform workspace select dev` and `terraform workspace select staging`, both workspaces read/write the **same state file**, causing:

- Resources from one workspace overwrite the other
- `terraform destroy` in staging deletes dev infrastructure
- Plan output shows unexpected changes from the other workspace

### Step-by-Step Fix

```bash
# 1. List current workspaces to see the problem
terraform workspace list

# 2. Fix the backend configuration (see below)

# 3. Reinitialize with the fixed backend key
terraform init -reconfigure

# 4. Migrate each workspace's state to its new path
terraform workspace select dev
terraform init -migrate-state

terraform workspace select staging
terraform init -migrate-state
```

### Fixed Code (backend block in main.tf)

**Option A: Use `workspace_key_prefix` (recommended)**

```hcl
terraform {
  backend "s3" {
    bucket               = "mycompany-terraform-state"
    key                  = "terraform.tfstate"
    region               = "us-east-1"
    dynamodb_table       = "terraform-state-locks"
    encrypt              = true
    workspace_key_prefix = "applications/web-app"
  }
}
```

This produces state paths like:
- `applications/web-app/dev/terraform.tfstate`
- `applications/web-app/staging/terraform.tfstate`

**Option B: Use separate key paths per environment (no workspaces)**

```hcl
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "applications/web-app/${terraform.workspace}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

> Note: `${terraform.workspace}` is NOT interpolated in backend blocks. Use `workspace_key_prefix` instead.

### Verification

```bash
# Switch to dev and confirm only dev resources
terraform workspace select dev
terraform state list
# Should show: web-app-dev-1

# Switch to staging and confirm only staging resources
terraform workspace select staging
terraform state list
# Should show: web-app-staging-1, web-app-staging-2

# Confirm state files are separate in S3
aws s3 ls s3://mycompany-terraform-state/applications/web-app/ --recursive
```
