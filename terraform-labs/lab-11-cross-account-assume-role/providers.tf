# Provider configuration for cross-account access
# Source account: 111122223333 (where Terraform runs)
# Target account: 444455556666 (where resources are managed)

# Provider for the source account (where Terraform executes)
provider "aws" {
  alias  = "source_account"
  region = "us-east-1"

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Team      = "platform-engineering"
    }
  }
}

# Provider for the target account (assumes role to manage resources)
# BUG 1: external_id doesn't match what's in the trust policy (iam.tf uses "TerraformExternal2024")
# BUG 2: session_duration is 43200 (12 hours) but the role max is 3600 (1 hour)
provider "aws" {
  alias  = "target_account"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::444455556666:role/TerraformCrossAccountRole"
    session_name = "TerraformCrossAccountSession"
    external_id  = "TerraformExternal2025"
    duration     = "12h"
  }

  default_tags {
    tags = {
      ManagedBy   = "terraform"
      SourceAcct  = "111122223333"
    }
  }
}
