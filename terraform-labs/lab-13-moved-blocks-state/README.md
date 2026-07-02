## 🎯 How to Use This Lab

1. Setup: `./deploy.sh` (copies broken .tf files to workspace)
2. Run: `cd workspace && terraform init && terraform plan`
3. Observe the error in terraform output
4. Fix the .tf files based on error message
5. Re-run `terraform validate` or `terraform plan` to verify
6. Check `solution.md` if stuck

---

# Lab 13: Moved Blocks and State Refactoring

## Difficulty: 🔴 Expert

## Estimated Time: 20-30 minutes

---

## Scenario

Your infrastructure team has been refactoring a large Terraform codebase to improve modularity. Previously, resources were defined at the root level using `count`. The refactoring moves them into a module that uses `for_each`.

The engineer added `moved` blocks to tell Terraform to move the state entries rather than destroying and recreating 20+ production resources. However, `terraform plan` still shows resources being **destroyed and recreated** instead of moved. The `moved` block addresses are incorrect in multiple ways.

This is a critical issue — the resources are production databases and storage buckets. Destroying them would cause data loss and an outage.

---

## Error Output

```
$ terraform plan

╷
│ Warning: Resource instance address refers to non-existent resource
│ 
│   on main.tf line 8:
│    8: moved {
│ 
│ The resource instance aws_instance.web[0] does not exist in the current configuration.
│ Did you mean module.compute.aws_instance.web["web-0"]?
╵

╷
│ Error: Moved object still exists
│ 
│   on main.tf line 18:
│   18: moved {
│ 
│ The "from" address module.legacy.aws_s3_bucket.data[0] does not match any resource
│ instance in the prior state. The "to" address module.refactored.aws_s3_bucket.data
│ also refers to a resource that would already exist at that address.
╵

╷
│ Error: Cross-package move statement
│ 
│   on main.tf line 28:
│   28: moved {
│ 
│ This statement declares a move from module.databases.module.primary.aws_rds_cluster.main
│ but the current module path is "root". Moved blocks can only refer to resources within
│ the same module package.
╵

Plan: 15 to add, 0 to change, 15 to destroy.

# Shows the old resources being destroyed:
  # aws_instance.web[0] will be destroyed
  # aws_instance.web[1] will be destroyed  
  # aws_instance.web[2] will be destroyed
  # aws_s3_bucket.data[0] will be destroyed
  # aws_s3_bucket.data[1] will be destroyed
  # aws_rds_cluster.main will be destroyed
  ...

# And new ones created under the module:
  # module.compute.aws_instance.web["web-0"] will be created
  # module.compute.aws_instance.web["web-1"] will be created
  # module.compute.aws_instance.web["web-2"] will be created
  # module.storage.aws_s3_bucket.data["bucket-0"] will be created
  # module.storage.aws_s3_bucket.data["bucket-1"] will be created
  # module.database.aws_rds_cluster.main will be created
  ...
```

---

## Hints

<details>
<summary>Hint 1</summary>
When moving from `count`-indexed resources to `for_each`, the `from` address uses `[0]`, `[1]`, etc., but the `to` address must use the `for_each` key. E.g., `from = aws_instance.web[0]` → `to = module.compute.aws_instance.web["web-0"]`. Check that the keys in your moved blocks match the actual for_each keys in the refactored module.
</details>

<details>
<summary>Hint 2</summary>
The moved block for the S3 buckets uses `module.legacy.aws_s3_bucket.data[0]` as the source, but the actual state has these at the root level: `aws_s3_bucket.data[0]`. The prefix `module.legacy` doesn't exist in state. Also, the `to` address omits the for_each key.
</details>

<details>
<summary>Hint 3</summary>
For nested modules, moved blocks in the root module can only reference resources within the same module tree. The RDS moved block references `module.databases.module.primary.aws_rds_cluster.main` but the actual state path is `aws_rds_cluster.main` (root level). The `to` path `module.database.aws_rds_cluster.main` is correct. Also check that module source paths point to the right directory.
</details>

---

## Troubleshooting Commands

```bash
# Initialize and check state
terraform init
terraform state list

# Look at what's in state currently
terraform state show 'aws_instance.web[0]'
terraform state show 'aws_s3_bucket.data[0]'
terraform state show 'aws_rds_cluster.main'

# Validate configuration
terraform validate

# Show detailed plan
terraform plan -no-color 2>&1 | tee plan-output.txt

# Check for specific resource addresses in state
terraform state list | grep -E "aws_instance|aws_s3_bucket|aws_rds_cluster"

# See what terraform thinks about moved blocks
TF_LOG=DEBUG terraform plan 2>&1 | grep -i "move\|moved"

# Inspect the module structure
find modules/ -name "*.tf" -exec head -5 {} \;

# Check for_each keys in the refactored module
terraform console
> module.compute.aws_instance.web

# If needed, manual state move as alternative
terraform state mv 'aws_instance.web[0]' 'module.compute.aws_instance.web["web-0"]'

# Dry-run state operations
terraform plan -target='module.compute'

# Show current state JSON for analysis
terraform state pull | jq '.resources[] | {type, name, module, instances: [.instances[].index_key]}'
```

---

## What to Fix

1. Fix moved block `from` address for instances — remove incorrect module prefix, resources are at root level
2. Fix `from` address for S3 buckets — they're at root `aws_s3_bucket.data[0]`, not `module.legacy.aws_s3_bucket.data[0]`
3. Fix `to` addresses to include correct `for_each` keys matching the refactored module
4. Fix nested module path for RDS — from address should be root-level `aws_rds_cluster.main`
5. Fix the module source path in the refactored module reference
6. Ensure moved blocks are in the correct module (root) to reference both old and new addresses
