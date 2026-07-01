# Lab 10 - Data Source Race Condition

## Difficulty: ⭐⭐⭐

## Scenario
A developer is trying to create an RDS instance and then immediately query it with a `data` source in the same Terraform configuration to get the endpoint for a Lambda function's environment variable. The problem is that `data` sources are evaluated at **plan time**, before any resources are created. The RDS instance doesn't exist yet, so the data source fails.

## Expected Error Output
```
╷
│ Error: Your query returned no results. Please change your search criteria 
│ and try again.
│
│   with data.aws_db_instance.app_db,
│   on main.tf line 58, in data "aws_db_instance" "app_db":
│   58: data "aws_db_instance" "app_db" {
│
╵
```

Or during plan:
```
╷
│ Error: no matching RDS Instance found
│
│   with data.aws_db_instance.app_db,
│   on main.tf line 58, in data "aws_db_instance" "app_db":
│   58: data "aws_db_instance" "app_db" {
│
│   db_instance_identifier = "app-database-prod"
╵
```

## Troubleshooting Steps

1. **Run terraform plan**: See the data source error
2. **Understand plan-time evaluation**: Data sources read during plan, resources don't exist yet
3. **Remove the data source**: Reference the resource directly instead
4. **Use resource attributes**: `aws_db_instance.app_db.endpoint` instead of data source

## Key Commands
```bash
terraform plan                    # Reproduce the error
terraform validate                # May also catch the issue
terraform graph                   # Visualize the dependency problem
```

## Root Cause
Data sources read existing infrastructure at plan time. If you need to reference attributes of a resource you're creating in the same config, use the resource's own output attributes directly — don't use a data source to query it.

## Prevention
- Never use a data source to query a resource defined in the same configuration
- Reference resource attributes directly (e.g., `aws_db_instance.main.endpoint`)
- Use data sources only for resources managed outside the current Terraform config
- Understand plan-time vs. apply-time evaluation
