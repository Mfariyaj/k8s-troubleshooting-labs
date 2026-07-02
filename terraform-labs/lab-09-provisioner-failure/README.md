## 🎯 How to Use This Lab

1. Setup: `./deploy.sh` (copies broken .tf files to workspace)
2. Run: `cd workspace && terraform init && terraform plan`
3. Observe the error in terraform output
4. Fix the .tf files based on error message
5. Re-run `terraform validate` or `terraform plan` to verify
6. Check `solution.md` if stuck

---

# Lab 09 - Provisioner Failure

## Difficulty: ⭐⭐⭐

## Scenario
An EC2 instance was created successfully, but the `remote-exec` provisioner failed because the user-data script path was wrong and SSH connectivity wasn't established in time. The resource is now **tainted** in state. Running `terraform apply` again will **destroy and recreate** the instance, causing downtime.

## Expected Error Output
```
aws_instance.app_server (remote-exec): Connecting to remote host via SSH...
aws_instance.app_server (remote-exec):   Host: 10.0.1.47
aws_instance.app_server (remote-exec):   User: ec2-user
aws_instance.app_server (remote-exec):   Password: false
aws_instance.app_server (remote-exec):   Private key: true
aws_instance.app_server (remote-exec):   Certificate: false
aws_instance.app_server: Still creating... [5m0s elapsed]

╷
│ Error: timeout - last error: dial tcp 10.0.1.47:22: i/o timeout
│
│   with aws_instance.app_server,
│   on main.tf line 25, in resource "aws_instance" "app_server":
│   25:   provisioner "remote-exec" {
│
╵

aws_instance.app_server: Tainting...
aws_instance.app_server: Taint complete
```

Then on next apply:
```
Terraform will perform the following actions:

  # aws_instance.app_server is tainted, so must be replaced
-/+ resource "aws_instance" "app_server" {
      ~ id = "i-0abc123def456" -> (known after apply)
      ...
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

## Troubleshooting Steps

1. **Check state for tainted resources**: `terraform state list` and `terraform show`
2. **Understand why it's tainted**: Provisioner failed, marking resource for recreation
3. **Remove taint if instance is fine**: `terraform untaint aws_instance.app_server`
4. **Fix the provisioner**: Correct the SSH/connection settings or remove the provisioner
5. **Apply cleanly**: Run `terraform apply` without destroying the instance

## Key Commands
```bash
terraform plan                                    # See the forced replacement
terraform state show aws_instance.app_server      # Check resource state
terraform untaint aws_instance.app_server         # Remove taint
terraform plan                                    # Verify no replacement needed
```

## Root Cause
When a provisioner fails, Terraform marks the resource as "tainted" — meaning it was created but not fully configured. On next apply, tainted resources are destroyed and recreated. This causes unnecessary downtime when the instance itself is fine.

## Prevention
- Avoid provisioners when possible — use user_data, cloud-init, or configuration management tools
- If using provisioners, set `on_failure = continue` for non-critical setup
- Use connection timeouts and retry logic
- Consider `null_resource` with provisioners (can be re-run without destroying the instance)
