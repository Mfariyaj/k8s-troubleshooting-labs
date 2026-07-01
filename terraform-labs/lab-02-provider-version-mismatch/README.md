# Lab 02 - Provider Version Mismatch

## Difficulty: ⭐

## Scenario
Your CI/CD pipeline suddenly fails on `terraform init`. A teammate committed an update to `.terraform.lock.hcl` that changed the provider hashes, but the `versions.tf` constraints no longer match. The lock file expects AWS provider 5.31.0 but the version constraint says `= 4.67.0`.

## Expected Error Output
```
╷
│ Error: Failed to query available provider packages
│
│ Could not retrieve the list of available versions for provider
│ hashicorp/aws: locked provider registry.terraform.io/hashicorp/aws 5.31.0
│ does not match configured version constraint = 4.67.0.
│
│ If you wish to upgrade to a newer version, run:
│   terraform init -upgrade
│
│ Otherwise, revert the changes to your lock file.
╵
```

## Troubleshooting Steps

1. **Read the error carefully**: The lock file and version constraint disagree
2. **Check versions.tf**: Find the version constraint that's too restrictive
3. **Check .terraform.lock.hcl**: See what version is actually locked
4. **Fix the constraint**: Update `versions.tf` to allow the locked version OR run `terraform init -upgrade`

## Key Commands
```bash
terraform init                    # Reproduce the error
cat versions.tf                   # Check the version constraint
cat .terraform.lock.hcl           # Check the locked version
terraform init -upgrade           # Upgrade lock to match constraints (one fix)
```

## Root Cause
The `.terraform.lock.hcl` file pins exact provider versions with cryptographic hashes. When someone changes the version constraint in `versions.tf` without running `terraform init -upgrade`, or vice versa, you get a mismatch.

## Prevention
- Always run `terraform init -upgrade` after changing version constraints
- Use version ranges (`~> 5.0`) instead of exact pins in version constraints
- Review lock file changes in PRs
