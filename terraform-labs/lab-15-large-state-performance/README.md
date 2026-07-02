## 🎯 How to Use This Lab

1. Setup: `./deploy.sh` (copies broken .tf files to workspace)
2. Run: `cd workspace && terraform init && terraform plan`
3. Observe the error in terraform output
4. Fix the .tf files based on error message
5. Re-run `terraform validate` or `terraform plan` to verify
6. Check `solution.md` if stuck

---

# Lab 15: Large State Performance Degradation

## Difficulty: 🔴 Expert

## Estimated Time: 20-30 minutes

---

## Scenario

Your enterprise platform manages 2000+ resources across 20 microservices. Terraform plan takes **45+ minutes** to complete. The state file is 50MB+, every plan refreshes all data sources (including expensive API calls to AWS), and the configuration has significant architectural issues causing unnecessary overhead.

Developers are frustrated — a simple tag change requires waiting nearly an hour for the plan. The CI/CD pipeline times out. The team needs immediate remediation strategies and longer-term refactoring advice.

---

## Error Output

```
$ time terraform plan

Refreshing Terraform state in-memory prior to plan...

data.aws_ami.latest_ubuntu: Refreshing...
data.aws_ami.latest_amazon_linux: Refreshing...
data.aws_availability_zones.available: Refreshing...
data.aws_vpc.main: Refreshing...
data.aws_subnets.private: Refreshing...
data.aws_subnets.public: Refreshing...
... (200+ data sources refreshing)
data.aws_secretsmanager_secret_version.service_secrets["api-gateway"]: Refreshing...
data.aws_secretsmanager_secret_version.service_secrets["user-service"]: Refreshing...
... (20 secrets, each takes 2-3 seconds due to API throttling)
data.aws_lb.service_alb["api-gateway"]: Refreshing...
... (20 ALB lookups)

module.microservice["api-gateway"].data.aws_availability_zones.available: Refreshing...
module.microservice["api-gateway"].data.aws_vpc.current: Refreshing...
module.microservice["api-gateway"].data.aws_caller_identity.current: Refreshing...
module.microservice["api-gateway"].data.aws_region.current: Refreshing...
... (80 redundant data sources inside modules: 20 services × 4 data sources each)

module.microservice["api-gateway"].aws_ecs_service.main: Refreshing state...
module.microservice["api-gateway"].aws_ecs_task_definition.main: Refreshing state...
... (2000+ resources refreshing)

# After 47 minutes:
Plan: 0 to add, 2 to change, 0 to destroy.

real    47m23.456s
user    3m12.789s
sys     0m45.123s

# With -refresh=false it's faster but has phantom diffs from orphans:
$ terraform plan -refresh=false
  # module.microservice["service-deprecated-01"].aws_ecs_service.main will be destroyed
  # module.microservice["service-deprecated-02"].aws_ecs_service.main will be destroyed
  ... (orphaned resources that no longer exist in config)

# State file size
$ ls -lh terraform.tfstate
-rw-r--r-- 1 terraform terraform 54M Jan 15 10:00 terraform.tfstate

$ terraform state list | wc -l
2347
```

---

## Hints

<details>
<summary>Hint 1</summary>
Look at the data sources — many are duplicated across modules. The microservice module has `data "aws_availability_zones"`, `data "aws_vpc"`, `data "aws_caller_identity"`, and `data "aws_region"` which are ALL re-evaluated for each of the 20 module instances (80 redundant API calls). These should be evaluated once at root and passed as variables.
</details>

<details>
<summary>Hint 2</summary>
The state contains resources from 8 decommissioned services (`service-deprecated-01` through `service-deprecated-08`). These orphaned resources exist in state but have no configuration, causing phantom diffs. Use `terraform state rm` or add `removed` blocks.
</details>

<details>
<summary>Hint 3</summary>
Use `-refresh=false` for development, `-target` for single-service changes, and `-parallelism=50` for faster API calls. Long-term: split into per-team state files and replace expensive data sources (Secrets Manager, AMI lookups) with variable inputs or SSM parameters.
</details>

---

## Troubleshooting Commands

```bash
# Check state file size and resource count
ls -lh terraform.tfstate
terraform state list | wc -l

# Find orphaned resources (in state but not in config)
terraform plan -refresh=false 2>&1 | grep "will be destroyed"

# List resources by type to find duplication
terraform state list | sed 's/\[.*//g' | sort | uniq -c | sort -rn | head -20

# Count data sources
terraform state list | grep "^data\." | wc -l

# Time a targeted plan vs full plan
time terraform plan -target='module.microservice["api-gateway"]' -refresh=false
time terraform plan -refresh=false

# Find duplicate data sources across modules
grep -r "data \"aws_" . --include="*.tf" | sort

# Count redundant data sources inside modules
grep -r "data \"aws_" modules/ --include="*.tf" | wc -l

# State analysis
terraform state pull | jq '.resources | length'
terraform state pull | jq '[.resources[].type] | group_by(.) | map({type:.[0], count:length}) | sort_by(-.count)[:10]'

# Find orphaned service resources
terraform state list | grep "deprecated"

# Run the included analysis script
./state-analysis.sh
```

---

## What to Fix

1. Remove redundant data sources from the microservice module — pass values from root as variables
2. Remove orphaned resources from state (`terraform state rm` or `removed` blocks)
3. Use `-refresh=false` for dev workflow, schedule `-refresh-only` runs separately
4. Replace expensive data sources (Secrets Manager, ALB) with variable inputs
5. Use `-parallelism=50` to allow more concurrent API calls
6. Use `-target` for single-service changes
7. Long-term: split monolithic state into per-team workspaces
