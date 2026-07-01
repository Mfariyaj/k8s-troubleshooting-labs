# Lab 14: Provider Crash / Panic During Plan - Broken Configuration
# This simulates provider incompatibility and configuration issues that cause crashes

terraform {
  required_version = ">= 1.3.0, < 1.5.0"  # BUG: This blocks Terraform 1.5+ (we're running 1.6)
}

# BUG: Provider block has required attributes set to empty/invalid values
# causing nil pointer dereference in the provider's Configure method
provider "monitoring" {
  # BUG: base_url uses HTTP, but provider v2+ requires HTTPS and panics on HTTP
  base_url = "http://monitoring.internal.company.com/api/v1"

  # BUG: auth_token is empty string - provider doesn't validate before using it,
  # causing nil pointer when building authenticated HTTP client
  auth_token = ""

  # These are fine
  environment = "production"
  retry_max   = 3
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.com/"
}

# ═══════════════════════════════════════════════════════════════
# Resources using the crashing provider
# ═══════════════════════════════════════════════════════════════

resource "monitoring_dashboard" "platform_overview" {
  name        = "Platform Overview - Production"
  description = "High-level platform metrics dashboard"

  layout = "grid"
  width  = 12

  widget {
    type  = "timeseries"
    title = "Request Rate"
    query = "sum:http.requests{env:production}.as_rate()"
    position {
      x      = 0
      y      = 0
      width  = 6
      height = 3
    }
  }

  widget {
    type  = "timeseries"
    title = "Error Rate"
    query = "sum:http.errors{env:production}.as_rate() / sum:http.requests{env:production}.as_rate() * 100"
    position {
      x      = 6
      y      = 0
      width  = 6
      height = 3
    }
  }

  tags = ["team:platform", "env:production"]
}

resource "monitoring_alert" "high_error_rate" {
  name    = "High Error Rate - Production"
  type    = "metric alert"
  message = <<-EOT
    Error rate is above 5% in production.
    
    @slack-platform-alerts @pagerduty-platform
  EOT

  query = "avg(last_5m):sum:http.errors{env:production}.as_rate() / sum:http.requests{env:production}.as_rate() * 100 > 5"

  thresholds = {
    critical = 5
    warning  = 3
  }

  notify_no_data = true
  evaluation_delay = 60

  tags = ["team:platform", "severity:high"]
}

resource "monitoring_slo" "api_availability" {
  name        = "API Availability SLO"
  type        = "metric"
  description = "99.9% availability for production API"

  query {
    numerator   = "sum:http.requests{env:production,status:2xx}.as_count()"
    denominator = "sum:http.requests{env:production}.as_count()"
  }

  thresholds {
    timeframe = "30d"
    target    = 99.9
    warning   = 99.95
  }

  tags = ["team:platform", "tier:critical"]
}

# Datadog resources (these work after fixing the source address)
resource "datadog_monitor" "cpu_high" {
  name    = "High CPU Usage"
  type    = "metric alert"
  message = "CPU usage is above 90% on {{host.name}}. @slack-infra-alerts"

  query = "avg(last_5m):avg:system.cpu.user{*} by {host} > 90"

  monitor_thresholds {
    critical = 90
    warning  = 80
  }

  notify_no_data    = false
  renotify_interval = 60

  tags = ["team:infrastructure", "env:production"]
}

# ═══════════════════════════════════════════════════════════════
# Variables
# ═══════════════════════════════════════════════════════════════

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
  default     = "placeholder-api-key-replace-me"
}

variable "datadog_app_key" {
  description = "Datadog Application key"
  type        = string
  sensitive   = true
  default     = "placeholder-app-key-replace-me"
}
