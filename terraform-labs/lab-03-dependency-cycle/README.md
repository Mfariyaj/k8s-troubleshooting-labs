## 🎯 How to Use This Lab

1. Setup: `./deploy.sh` (copies broken .tf files to workspace)
2. Run: `cd workspace && terraform init && terraform plan`
3. Observe the error in terraform output
4. Fix the .tf files based on error message
5. Re-run `terraform validate` or `terraform plan` to verify
6. Check `solution.md` if stuck

---

# Lab 03 - Dependency Cycle

## Difficulty: ⭐⭐

## Scenario
A junior engineer wrote Terraform code for an EC2 instance with a security group. They referenced the security group from the instance (for `vpc_security_group_ids`) and also referenced the instance from the security group (trying to add the instance's private IP to an ingress rule). This creates a circular dependency that Terraform cannot resolve.

## Expected Error Output
```
╷
│ Error: Cycle: aws_security_group.app, aws_instance.web_server
│
╵
```

## Troubleshooting Steps

1. **Run terraform validate**: See the cycle error
2. **Identify the cycle**: Find which resources reference each other
3. **Break the cycle**: Use a separate `aws_security_group_rule` resource or remove the circular reference
4. **Validate again**: Confirm the cycle is resolved

## Key Commands
```bash
terraform validate                    # Reproduce the cycle error
terraform graph | dot -Tpng > graph.png   # Visualize dependencies (optional)
terraform plan                        # Verify fix works
```

## Root Cause
Terraform builds a dependency graph before execution. When resource A references an attribute of resource B, and resource B references an attribute of resource A, Terraform cannot determine which to create first. This is a cycle.

## Prevention
- Never reference an instance from its own security group (use separate rule resources)
- Use `terraform graph` to visualize complex dependencies
- Break cycles with intermediate resources or `aws_security_group_rule`
