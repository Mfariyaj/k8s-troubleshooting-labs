# Lab 04 - Remote Backend Bootstrap (Chicken-and-Egg Problem)

## Difficulty: ⭐⭐

## Scenario
A new team member tried to set up Terraform with a remote S3 backend. They defined the S3 bucket and DynamoDB table in the same Terraform configuration that uses them as the backend. When they run `terraform init`, it fails because the backend bucket doesn't exist yet. But they can't create the bucket without running `terraform init` first!

## Expected Error Output
```
Initializing the backend...

╷
│ Error: Failed to get existing workspaces
│
│ S3 bucket "my-new-terraform-state-bucket" does not exist.
│
│ The referenced S3 bucket must have been previously created. If the S3 bucket
│ was recently created, please retry after a few seconds.
╵
```

## Troubleshooting Steps

1. **Understand the problem**: Backend must exist BEFORE `terraform init`
2. **Bootstrap approach**: Comment out backend, create resources with local state, then migrate
3. **OR**: Create the backend resources manually / with a separate bootstrap config
4. **Migrate state**: Re-enable backend and run `terraform init -migrate-state`

## Key Commands
```bash
terraform init                          # Reproduce the error
# Fix: Comment out backend block, then:
terraform init                          # Init with local state
terraform apply                         # Create the S3 bucket and DynamoDB table
# Uncomment backend block, then:
terraform init -migrate-state           # Migrate local state to new backend
```

## Root Cause
Terraform's backend configuration is evaluated during `terraform init`, before any resources are created. If the backend references infrastructure that doesn't exist yet, init fails. This is the classic "chicken-and-egg" problem.

## Prevention
- Use a separate "bootstrap" Terraform configuration for backend resources
- Create backend resources manually or with CloudFormation first
- Keep backend infrastructure in a different state than application infrastructure
