## Solution: Data Source Race Condition

### Root Cause

The `data "aws_db_instance" "app_db"` block tries to look up an RDS instance (`app-database-prod`) that is being **created** in the same configuration by `resource "aws_db_instance" "app_db"`. Data sources are evaluated during the plan phase, before any resources are created:

```
Error: Your query returned no results. Please change your search criteria and try again.
```

The Lambda function and Route53 record reference `data.aws_db_instance.app_db.endpoint` instead of using the resource attribute directly.

### Step-by-Step Fix

1. **Remove the data source** — it's unnecessary since we have the resource
2. **Replace all `data.aws_db_instance.app_db.*` references** with `aws_db_instance.app_db.*`

### Fixed Code (main.tf)

```hcl
# REMOVE this data source entirely:
# data "aws_db_instance" "app_db" {
#   db_instance_identifier = "app-database-prod"
# }

# Fix Lambda to reference the RESOURCE directly (not data source)
resource "aws_lambda_function" "app" {
  function_name = "app-api-handler"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "lambda.zip"

  environment {
    variables = {
      DB_HOST     = aws_db_instance.app_db.endpoint      # Fix: use resource reference
      DB_PORT     = aws_db_instance.app_db.port          # Fix: use resource reference
      DB_NAME     = "appdb"
      DB_USER     = "appadmin"
      ENVIRONMENT = "production"
    }
  }

  # Add explicit dependency to ensure DB is created first
  depends_on = [aws_db_instance.app_db]

  tags = {
    Name        = "app-api-handler"
    Environment = "production"
  }
}

# Fix Route53 record to use resource reference
resource "aws_route53_record" "db" {
  zone_id = "Z1234567890ABC"
  name    = "db.internal.mycompany.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.app_db.address]  # Fix: use resource reference
}

# Fix output
output "db_endpoint" {
  value = aws_db_instance.app_db.endpoint  # Fix: use resource reference
}
```

### Verification

```bash
# Validate — should find no errors about missing data source
terraform validate

# Plan — should show create for RDS + Lambda + Route53 in correct order
terraform plan

# The dependency graph should show Lambda depends on RDS
terraform graph | grep -A2 "lambda"
```

### Key Takeaway

- Use `data` sources only for resources managed **outside** your configuration
- For resources in the same config, always reference the `resource` block directly
- If you must use a data source for a resource created in the same apply, add `depends_on`
