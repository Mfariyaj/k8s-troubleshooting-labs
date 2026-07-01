terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # BUG: This constraint says exactly 4.67.0, but the lock file has 5.31.0
      version = "= 4.67.0"
    }
  }
}
