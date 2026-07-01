# Provider version constraints - multiple issues here

terraform {
  required_providers {
    # BUG: Source address is case-sensitive - should be "DataDog/datadog"
    # On Linux/Mac registries, "datadog/datadog" resolves to a different namespace
    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.0.0, < 3.21.0"  # BUG: Excludes v3.21.0 which has the crash fix
    }

    # BUG: Source namespace is wrong - provider migrated from "custom-corp" to "customcorp"
    # The old namespace returns a redirect that Terraform < 1.5 followed but 1.6 doesn't
    # BUG: Version constraint ~> 1.2 pulls v1.2.3 which uses protocol 5
    # Terraform 1.6 only supports protocol 6 - need ~> 2.0
    monitoring = {
      source  = "custom-corp/monitoring"
      version = "~> 1.2"
    }
  }
}
