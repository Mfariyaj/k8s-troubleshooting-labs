## Solution: Backend Bootstrap (Chicken-and-Egg Problem)

### Root Cause

The configuration defines an S3 backend (`my-new-terraform-state-bucket`) while also trying to *create* that same bucket in the same config. `terraform init` fails because the backend bucket doesn't exist yet:

```
Error: Failed to get existing workspaces: S3 bucket does not exist.
The referenced S3 bucket must be created before initializing the backend.
```

This is a classic bootstrap problem — you can't store state in infrastructure you haven't created yet.

### Step-by-Step Fix (Two-Phase Approach)

**Phase 1: Create backend resources with local state**

```bash
# 1. Comment out or remove the backend "s3" block
# 2. Initialize with local state
terraform init

# 3. Create the S3 bucket and DynamoDB table
terraform apply

# 4. Verify resources exist
aws s3 ls | grep my-new-terraform-state-bucket
aws dynamodb describe-table --table-name my-new-terraform-locks --region us-east-1
```

**Phase 2: Migrate state to the new backend**

```bash
# 5. Uncomment the backend "s3" block
# 6. Reinitialize — Terraform will offer to migrate local state to S3
terraform init -migrate-state

# Answer "yes" to copy existing state to the new backend
```

### Fixed Code (main.tf — Phase 1: comment out backend)

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # PHASE 1: Comment this out, apply, then uncomment and run terraform init -migrate-state
  # backend "s3" {
  #   bucket         = "my-new-terraform-state-bucket"
  #   key            = "infrastructure/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "my-new-terraform-locks"
  #   encrypt        = true
  # }
}
```

### Verification

```bash
# After Phase 2, confirm state is in S3
terraform state list

# Confirm backend is configured
terraform init

# Verify plan shows no changes (state migrated correctly)
terraform plan
# Expected: "No changes. Your infrastructure matches the configuration."
```
