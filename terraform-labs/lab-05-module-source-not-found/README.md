# Lab 05 - Module Source Not Found

## Difficulty: ⭐⭐

## Scenario
Your team is using private modules from a Terraform registry and local module paths. After a repository restructure, module source paths were updated incorrectly. One module points to a non-existent registry namespace, another has an impossible version constraint, and a local module path is wrong.

## Expected Error Output
```
Initializing modules...
╷
│ Error: Module not found
│
│ Module "vpc" (main.tf:15) could not be found in the registry at
│ registry.terraform.io.
│
│ Module "networking" could not be downloaded: 
│ Could not download module "networking" source code from
│ "git::https://github.com/nonexistent-org/terraform-aws-network.git?ref=v99.0.0":
│ error downloading
│ 'https://github.com/nonexistent-org/terraform-aws-network.git?ref=v99.0.0':
│ repository not found
│
│ Error: Module version requirements have no available releases.
│ Module "compute" (main.tf:29) version ">= 99.0.0" has no available releases.
╵
```

## Troubleshooting Steps

1. **Run terraform init**: See which modules fail to download
2. **Check each module source**: Verify registry paths, git URLs, and local paths
3. **Fix the sources**: Correct the module source URLs and version constraints
4. **Re-run terraform init**: Confirm all modules download successfully

## Key Commands
```bash
terraform init                    # Reproduce the error
terraform get                     # Download modules only
cat main.tf                       # Check module source declarations
```

## Root Cause
Module source URLs must exactly match the registry namespace/name/provider format, git repository URLs must exist, and version constraints must be satisfiable. Any typo or wrong reference causes init to fail.

## Prevention
- Use `.terraformrc` or `terraformrc` for private registry credentials
- Pin module versions with exact constraints
- Test module references in CI before merging
