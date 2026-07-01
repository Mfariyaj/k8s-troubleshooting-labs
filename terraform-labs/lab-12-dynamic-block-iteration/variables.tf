# Variables for complex dynamic block iteration lab

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
  default     = "vpc-0a1b2c3d4e5f67890"
}

variable "security_rules" {
  description = "Complex nested structure defining security rules per application"
  type = list(object({
    app_name    = string
    environment = string
    rules = list(object({
      description = string
      protocol    = string
      port_ranges = list(object({
        from_port = number
        to_port   = number
      }))
      cidrs = list(string)
    }))
  }))
}

variable "egress_rules" {
  description = "Egress rules - may be null in some environments"
  type = list(object({
    description = string
    protocol    = string
    from_port   = number
    to_port     = number
    cidrs       = list(string)
  }))
  default = null
}

variable "enable_egress" {
  description = "Whether to enable custom egress rules"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "team" {
  description = "Owning team"
  type        = string
  default     = "platform"
}
