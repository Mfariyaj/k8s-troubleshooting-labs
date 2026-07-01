# Lab 08 - Workspace State Collision

## Difficulty: ⭐⭐⭐

## Scenario
Your team uses Terraform workspaces to manage dev and staging environments. Someone misconfigured the backend so that both workspaces write to the same S3 state key path. When you switch workspaces and apply, it overwrites the other environment's state, causing resources to be orphaned or destroyed.

## Expected Error Output
```
$ terraform workspace select staging
Switched to workspace "staging".

$ terraform plan
Terraform will perform the following actions:

  # aws_instance.app[0] must be replaced
  -/+ resource "aws_instance" "app" {
      ~ tags = {
          ~ "Environment" = "dev" -> "staging"   # WAIT - why is it showing "dev"?!
        }
    }

  # aws_instance.app[1] must be replaced
  ...

Plan: 3 to add, 0 to change, 3 to destroy.
  
  # This is WRONG - it's reading dev's state and trying to modify dev resources!
```

## Troubleshooting Steps

1. **Check the backend configuration**: Look for the state key path
2. **Notice the bug**: The key doesn't include `${terraform.workspace}` or workspace differentiation
3. **Verify both workspaces see same state**: Switch workspaces and compare `terraform state list`
4. **Fix the key path**: Include workspace name in the state key

## Key Commands
```bash
terraform workspace list                    # List workspaces
terraform workspace select dev              # Switch to dev
terraform state list                        # See what's in state
terraform workspace select staging          # Switch to staging
terraform state list                        # Compare - they're the same!
cat backend.tf                              # Find the missing workspace differentiation
```

## Root Cause
When using Terraform workspaces with S3 backend, each workspace needs a unique state path. If the `key` in the backend config is static (doesn't include the workspace name), all workspaces share the same state file and overwrite each other.

## Prevention
- Include workspace in the key: `key = "env:/${terraform.workspace}/terraform.tfstate"`
- OR use workspace_key_prefix in the backend config
- Test workspace isolation before deploying to production
