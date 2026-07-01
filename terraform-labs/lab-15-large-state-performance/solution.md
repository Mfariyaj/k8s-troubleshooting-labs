## Solution: Large State Performance Degradation

### Root Cause

The configuration manages 2000+ resources with severe performance issues:

1. **Expensive data sources evaluated every plan** — `aws_secretsmanager_secret_version`, `aws_lb`, and `aws_iam_policy_document` are called for each of 20 services (60+ API calls per plan)
2. **No use of `-refresh=false` or `-target`** — full refresh of 2000+ resources takes 45+ minutes
3. **Orphaned deprecated services** — 8 dead services still in state, adding refresh overhead
4. **Module called 20x with `for_each`** — each module instance may contain its own data source lookups
5. **Default parallelism too low** — `parallelism=10` for 2000+ resources

### Step-by-Step Fix

**Immediate: Speed up plan/apply cycles**

```bash
# Skip refresh for quick plans (when you know state is current)
terraform plan -refresh=false

# Target specific services when making changes to one service
terraform plan -target='module.microservice["api-gateway"]'
terraform apply -target='module.microservice["api-gateway"]'

# Increase parallelism for large applies
terraform apply -parallelism=30
```

**Remove orphaned resources from state:**

```bash
# List deprecated services still in state
terraform state list | grep deprecated

# Remove each orphaned resource
terraform state rm 'module.microservice["service-deprecated-01"]'
terraform state rm 'module.microservice["service-deprecated-02"]'
terraform state rm 'module.microservice["service-deprecated-03"]'
terraform state rm 'module.microservice["service-deprecated-04"]'
terraform state rm 'module.microservice["service-deprecated-05"]'
terraform state rm 'module.microservice["service-deprecated-06"]'
terraform state rm 'module.microservice["service-deprecated-07"]'
terraform state rm 'module.microservice["service-deprecated-08"]'
```

**Architectural fix: Split into smaller state files**

```bash
# Move groups of services into separate configurations
terraform state mv 'module.microservice["payment-service"]' -state-out=payments/terraform.tfstate
terraform state mv 'module.microservice["billing-service"]' -state-out=payments/terraform.tfstate
```

### Fixed Code (main.tf — reduce data source overhead)

```hcl
# Fix: Lookup secrets ONCE using a single data source with known ARN pattern
# Instead of per-service data source lookups, pass secret ARN pattern to module
locals {
  secret_arn_prefix = "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:production"
}

data "aws_caller_identity" "current" {}

# Fix: Remove per-service ALB lookups — pass ALB ARN via variable or use resource references
# Fix: Use a single IAM policy document template instead of 20 identical ones
data "aws_iam_policy_document" "service_task_policy_template" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["${local.secret_arn_prefix}/*"]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::company-artifacts-*"]
  }
}

# Fix: Remove deprecated_services from locals.services map
# Fix: Remove for_each data sources that can be templated
```

### Verification

```bash
# Measure plan time improvement
time terraform plan -refresh=false

# Confirm orphaned resources are removed
terraform state list | wc -l

# Full plan with refresh (should be faster now)
time terraform plan

# Confirm no errors about missing deprecated resources
terraform plan 2>&1 | grep -i error
```

### Performance Targets

| Metric | Before | After |
|--------|--------|-------|
| Plan time | 45+ min | < 5 min |
| State resources | 2000+ | ~1500 |
| API calls per plan | 60+ data sources | ~10 |
| Parallelism | 10 (default) | 30 |
