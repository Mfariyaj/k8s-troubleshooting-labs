## Solution: State Lock Conflict

### Root Cause

Terraform uses a DynamoDB table (`terraform-state-locks`) to acquire a lock before modifying state stored in S3. A previous `terraform apply` or `terraform plan` crashed or was interrupted (Ctrl+C, network timeout, CI/CD job killed) without releasing the lock. Now every new operation fails with:

```
Error: Error acquiring the state lock
Lock Info:
  ID:        <LOCK_ID>
  Path:      prod/network/terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@hostname
  Created:   2024-01-15 10:32:00.000000000 +0000 UTC
```

### Step-by-Step Fix

1. **Confirm the lock is stale** — verify no other Terraform process is actually running:
   ```bash
   # Check if anyone else is running terraform
   aws dynamodb get-item \
     --table-name terraform-state-locks \
     --key '{"LockID": {"S": "mycompany-terraform-state/prod/network/terraform.tfstate"}}' \
     --region us-east-1
   ```

2. **Force-unlock the state** using the Lock ID from the error message:
   ```bash
   terraform force-unlock <LOCK_ID>
   ```
   Confirm with `yes` when prompted.

3. **Verify operations work again:**
   ```bash
   terraform plan
   ```

### Fixed Configuration (backend.tf — no code change needed)

The backend configuration itself is correct. The fix is operational:

```hcl
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "prod/network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

### Verification

```bash
# Confirm the lock is released
terraform plan

# Verify state is accessible
terraform state list

# Check DynamoDB lock table is clear
aws dynamodb scan --table-name terraform-state-locks --region us-east-1
```

### Prevention

- Use CI/CD runners with proper timeout handling
- Wrap long applies: `timeout 3600 terraform apply -auto-approve`
- Monitor for stale locks older than 1 hour
