## 🎯 How to Use This Lab

1. Setup: `./deploy.sh` (copies broken .tf files to workspace)
2. Run: `cd workspace && terraform init && terraform plan`
3. Observe the error in terraform output
4. Fix the .tf files based on error message
5. Re-run `terraform validate` or `terraform plan` to verify
6. Check `solution.md` if stuck

---

# Lab 12: Dynamic Block Iteration Failures

## Difficulty: 🔴 Expert

## Estimated Time: 15-25 minutes

---

## Scenario

A senior engineer is building a reusable security group module using **dynamic blocks** with complex nested iteration. The module accepts a variable structure defining security group rules for multiple applications, environments, and port ranges.

The expected outcome is a security group with precisely defined ingress/egress rules for a microservices platform. However, `terraform plan` either throws errors or produces **incorrect infrastructure** — the number of rules doesn't match expectations, some rules get null CIDR blocks, and the nested dynamic block uses the wrong iterator causing port ranges to be swapped.

This is a common pitfall for engineers transitioning from simple dynamic blocks to complex nested iteration patterns with `for_each`, `flatten()`, and conditional dynamics.

---

## Error Output

```
$ terraform plan

╷
│ Error: Incorrect attribute value type
│ 
│   on main.tf line 42, in resource "aws_security_group" "microservices":
│    42:       cidr_blocks = ingress.value.cidrs
│ 
│ Inappropriate value for attribute "cidr_blocks": element 0: string required.
╵

# After attempting to fix the cidr_blocks issue:
$ terraform plan

╷
│ Error: Invalid dynamic for_each value
│ 
│   on main.tf line 55, in resource "aws_security_group" "microservices":
│    55:       for_each = port_range.value.ports
│ 
│ Cannot use a list of object as the for_each value. A map or set of strings is required.
╵

# After converting to set, plan succeeds but produces wrong results:
$ terraform plan
Plan: 1 to add, 0 to change, 0 to destroy.

# But `terraform show` after apply reveals:
# - Only 3 ingress rules instead of expected 12
# - Egress rules have null CIDR blocks
# - Port ranges show from_port=443 to_port=80 (swapped)
```

---

## Hints

<details>
<summary>Hint 1</summary>
The `security_rules` variable is a list of objects containing nested lists. When you use `for_each` on this directly in a dynamic block, you get one iteration per top-level object. You need to `flatten()` the structure first to get one iteration per rule. Check how `local.flattened_rules` is constructed.
</details>

<details>
<summary>Hint 2</summary>
When you have nested dynamic blocks (e.g., a dynamic "ingress" containing iteration over port ranges), the inner iteration must reference the correct iterator. If the outer dynamic uses `iterator = "rule"`, the inner for_each must reference `rule.value.ports`, not `ingress.value.ports`. Also check the iterator name in the nested dynamic — it shadows the outer one if named the same.
</details>

<details>
<summary>Hint 3</summary>
The conditional dynamic block for egress uses `var.enable_egress ? var.egress_rules : []`. But if `egress_rules` is null (not an empty list), this evaluates to `null` when enable_egress is false, causing the dynamic to produce null cidr_blocks. Also check that `from_port` and `to_port` assignments aren't swapped inside the nested dynamic.
</details>

---

## Troubleshooting Commands

```bash
# Initialize and validate
terraform init
terraform validate

# Plan with detailed output
terraform plan -out=tfplan
terraform show -json tfplan | jq '.planned_values.root_module.resources[].values.ingress'

# Debug the locals/expressions
terraform console
> local.flattened_rules
> var.security_rules
> flatten([for app in var.security_rules : [for rule in app.rules : { ... }]])

# Check what for_each resolves to
terraform console
> { for idx, rule in local.flattened_rules : "${rule.app}-${rule.port}" => rule }

# Count expected rules
terraform console
> length(local.flattened_rules)

# See the full planned security group
terraform plan -out=plan.tfplan
terraform show -json plan.tfplan | jq '.planned_values.root_module.resources[] | select(.type == "aws_security_group") | .values.ingress'

# Validate variable structure
terraform console
> var.security_rules[0].rules

# Enable trace-level logging for expression evaluation
TF_LOG=TRACE terraform plan 2>&1 | grep -A5 "eval"

# Check for null values in dynamic blocks
terraform console
> var.enable_egress ? var.egress_rules : []

# Dry-run with variable override
terraform plan -var='enable_egress=false'
```

---

## What to Fix

1. Add `flatten()` to the local that builds the iterable for the dynamic ingress block
2. Fix the nested dynamic iterator name — it references the wrong parent iterator
3. Swap `from_port` and `to_port` assignments in the nested port range dynamic
4. Fix the conditional egress dynamic to handle null vs empty list correctly
5. Ensure CIDR blocks are passed as a list, not a nested list-of-lists
