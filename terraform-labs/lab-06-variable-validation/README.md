# Lab 06 - Variable Validation Failures

## Difficulty: ⭐⭐

## Scenario
Your team implemented strict variable validations to enforce naming conventions, valid CIDR blocks, and allowed instance types. A new deployment fails because the `terraform.tfvars` file contains values that violate multiple validation rules. The types are also wrong in some cases (number where string expected, list where map expected).

## Expected Error Output
```
╷
│ Error: Invalid value for variable
│
│   on variables.tf line 5:
│    5: variable "environment" {
│
│ The environment must be one of: dev, staging, production.
│ Got: "prod"
│
│ This was checked by the validation rule at variables.tf:12,3-13.
╵

╷
│ Error: Invalid value for variable
│
│   on variables.tf line 23:
│   23: variable "instance_type" {
│
│ Instance type must start with 't3.' or 'm5.' prefix.
│ Got: "c5.xlarge"
╵

╷
│ Error: Incorrect variable type
│
│   on terraform.tfvars line 7:
│    7: vpc_cidr = 10
│
│ The given value is not suitable for variable "vpc_cidr" defined at
│ variables.tf:35: string required.
╵
```

## Troubleshooting Steps

1. **Run terraform plan**: See all validation errors
2. **Read variables.tf**: Understand the validation rules
3. **Check terraform.tfvars**: Find values that violate rules or have wrong types
4. **Fix the values**: Correct types and values to pass validation

## Key Commands
```bash
terraform plan                    # Reproduce validation errors
cat variables.tf                  # Read the validation rules
cat terraform.tfvars              # See the problematic values
terraform console                 # Test expressions interactively
```

## Root Cause
Terraform variable validation blocks enforce constraints at plan time. When `terraform.tfvars` provides values that don't match the variable type or fail the validation condition, terraform plan fails immediately.

## Prevention
- Document allowed values in variable descriptions
- Use CI to validate tfvars before apply
- Provide sensible defaults where possible
