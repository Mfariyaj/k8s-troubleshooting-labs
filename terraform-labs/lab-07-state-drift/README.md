# Lab 07 - State Drift

## Difficulty: ⭐⭐⭐

## Scenario
Your company's production RDS instance was manually modified in the AWS console during an emergency. Someone changed the instance class from `db.t3.medium` to `db.r5.xlarge`, disabled Multi-AZ, and changed the backup retention period. When you run `terraform plan`, it shows unexpected changes that would revert the emergency modifications.

## Expected Error Output
```
Terraform will perform the following actions:

  # aws_db_instance.production will be updated in-place
  ~ resource "aws_db_instance" "production" {
      ~ instance_class         = "db.r5.xlarge" -> "db.t3.medium"
      ~ multi_az               = false -> true
      ~ backup_retention_period = 3 -> 7
        # (15 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

─────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee that exactly these actions will be performed if "terraform apply"
is subsequently run.
```

## Troubleshooting Steps

1. **Run terraform plan**: See the unexpected drift
2. **Understand what changed**: Real infra differs from code
3. **Decide approach**: Update code to match reality OR revert reality to match code
4. **If keeping manual changes**: Update main.tf to match the new values, then run `terraform plan` to confirm no changes
5. **If reverting**: Just run `terraform apply` to force infrastructure back to code

## Key Commands
```bash
terraform plan                          # See the drift
terraform refresh                       # Update state from real infra (deprecated, use plan -refresh-only)
terraform plan -refresh-only            # Show drift without proposing changes
terraform apply -refresh-only           # Update state to match reality
terraform import                        # Import manually created resources
```

## Root Cause
State drift occurs when infrastructure is modified outside of Terraform (AWS Console, CLI, other tools). Terraform's state file becomes stale, and the next plan shows changes to "fix" the drift by reverting to what's in code.

## Prevention
- Implement SCPs or IAM policies preventing manual changes to Terraform-managed resources
- Run drift detection on a schedule (e.g., `terraform plan` in CI nightly)
- Tag all Terraform-managed resources and alert on untagged modifications
- Use AWS Config rules to detect non-compliant changes
