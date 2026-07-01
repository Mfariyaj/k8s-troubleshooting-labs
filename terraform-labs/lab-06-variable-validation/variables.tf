variable "environment" {
  description = "Deployment environment (must be dev, staging, or production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "The environment must be one of: dev, staging, production."
  }
}

variable "project_name" {
  description = "Project name (must be lowercase alphanumeric with hyphens, 3-20 chars)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,19}$", var.project_name))
    error_message = "Project name must be lowercase, start with a letter, contain only letters/numbers/hyphens, and be 3-20 characters."
  }
}

variable "instance_type" {
  description = "EC2 instance type (must be t3 or m5 family)"
  type        = string

  validation {
    condition     = can(regex("^(t3|m5)\\.", var.instance_type))
    error_message = "Instance type must start with 't3.' or 'm5.' prefix."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "instance_count" {
  description = "Number of instances (must be between 1 and 10)"
  type        = number

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "allowed_ports" {
  description = "List of allowed ingress ports"
  type        = list(number)

  validation {
    condition     = alltrue([for port in var.allowed_ports : port > 0 && port <= 65535])
    error_message = "All ports must be valid (1-65535)."
  }
}

variable "tags" {
  description = "Resource tags (must include 'Owner' key)"
  type        = map(string)

  validation {
    condition     = contains(keys(var.tags), "Owner")
    error_message = "Tags must include an 'Owner' key."
  }
}
