## Solution: Provider Crash / Panic During Plan

### Root Cause

Multiple provider configuration issues cause crashes and initialization failures:

1. **`required_version = ">= 1.3.0, < 1.5.0"`** — blocks Terraform 1.5+ (we're running 1.6+)
2. **Datadog provider source** — `datadog/datadog` should be `DataDog/datadog` (case-sensitive namespace)
3. **Monitoring provider source** — `custom-corp/monitoring` migrated to `customcorp/monitoring`
4. **Monitoring provider version** — `~> 1.2` uses protocol 5; need `~> 2.0` for protocol 6
5. **Provider `base_url` uses HTTP** — provider v2+ requires HTTPS and panics on HTTP
6. **`auth_token = ""`** — empty string causes nil pointer dereference in the provider

### Step-by-Step Fix

```bash
# 1. Fix versions.tf and main.tf (see below)
# 2. Clear cached providers
rm -rf .terraform .terraform.lock.hcl

# 3. Reinitialize
terraform init

# 4. Validate and plan
terraform validate
terraform plan
```

### Fixed Code (versions.tf)

```hcl
terraform {
  required_providers {
    # Fix: Correct case-sensitive namespace
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.21"  # Fix: include v3.21.0+ which has crash fix
    }

    # Fix: Correct namespace (no hyphen) and version for protocol 6
    monitoring = {
      source  = "customcorp/monitoring"
      version = "~> 2.0"  # Fix: v2.0+ supports protocol 6
    }
  }
}
```

### Fixed Code (main.tf — terraform block and provider)

```hcl
terraform {
  required_version = ">= 1.5.0"  # Fix: allow Terraform 1.5+
}

provider "monitoring" {
  # Fix: Use HTTPS (provider v2+ panics on HTTP)
  base_url = "https://monitoring.internal.company.com/api/v1"

  # Fix: Provide a valid auth token (not empty string)
  auth_token = var.monitoring_api_token

  environment = "production"
  retry_max   = 3
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.com/"
}

variable "monitoring_api_token" {
  description = "Monitoring platform API token"
  type        = string
  sensitive   = true
}
```

### Verification

```bash
# Confirm terraform version is accepted
terraform version

# Initialize with fixed providers
terraform init

# Validate configuration
terraform validate

# Plan should complete without crash/panic
terraform plan

# If you see "panic:" in output, check provider version compatibility
terraform providers
```
