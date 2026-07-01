# Lab 01 - State Lock Conflict

## Difficulty: ⭐

## Scenario
Your teammate was running `terraform apply` on the shared infrastructure project when their laptop crashed mid-operation. The apply was using a DynamoDB table for state locking. Now when you try to run `terraform plan`, you get a lock error because the stale lock was never released.

## Expected Error Output
```
╷
│ Error: Error acquiring the state lock
│
│ Error message: ConditionalCheckFailedException: The conditional request failed
│ Lock Info:
│   ID:        a]1b2c3d4-e5f6-7890-abcd-ef1234567890
│   Path:      s3://mycompany-terraform-state/prod/network/terraform.tfstate
│   Operation: OperationTypeApply
│   Who:       john.doe@laptop-abc
│   Version:   1.5.7
│   Created:   2024-01-15 14:23:45.123456 +0000 UTC
│   Info:
│
│ Terraform acquires a state lock to protect the state from being written
│ by multiple users at the same time. Please resolve the issue above and try
│ again. For most commands, you can disable locking with the "-lock=false"
│ flag, but this is not recommended.
╵
```

## Troubleshooting Steps

1. **Identify the lock holder**: Check who holds the lock and when it was created
2. **Verify the lock is stale**: Confirm the operation is no longer running
3. **Force unlock**: Use `terraform force-unlock <LOCK_ID>` to release the stale lock
4. **Verify recovery**: Run `terraform plan` to confirm operations work again

## Key Commands
```bash
terraform plan                              # Reproduce the error
terraform force-unlock <LOCK_ID>           # Release the stale lock
terraform plan -lock=false                  # Bypass lock (NOT recommended for production)
```

## Root Cause
When a Terraform operation is interrupted (crash, network failure, killed process), the DynamoDB lock entry is not cleaned up. The lock persists until manually released or TTL expires (if configured).

## Prevention
- Configure DynamoDB TTL on the lock table
- Use CI/CD pipelines instead of local applies
- Implement alerting for locks older than N minutes
