# Lab 12: Dynamic Block Iteration - Broken Configuration
# Complex dynamic blocks with nested for_each producing wrong infrastructure

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# BUG 1: Missing flatten() - this creates a list-of-lists instead of a flat list
# When security_rules has apps with multiple rules, we need to flatten to get individual rules
locals {
  # This produces [[rule1, rule2], [rule3, rule4]] instead of [rule1, rule2, rule3, rule4]
  # Missing flatten() call around the outer for expression
  flattened_rules = [
    for app in var.security_rules : [
      for rule in app.rules : {
        app_name    = app.app_name
        environment = app.environment
        description = rule.description
        protocol    = rule.protocol
        port_ranges = rule.port_ranges
        cidrs       = rule.cidrs
      }
    ]
  ]
}

resource "aws_security_group" "microservices" {
  name        = "microservices-${var.environment}"
  description = "Security group for microservices platform - ${var.environment}"
  vpc_id      = var.vpc_id

  # BUG 2: for_each gets a list-of-lists from flattened_rules (not actually flattened)
  # This means we iterate over inner lists, not individual rules
  dynamic "ingress" {
    for_each = local.flattened_rules
    iterator = rule

    content {
      # BUG 3: rule.value is a list (inner list), not a single rule object
      # This causes "element 0: string required" because cidrs is a list within a list
      description = rule.value.description
      protocol    = rule.value.protocol

      # Nested dynamic for port ranges
      # BUG 4: Wrong iterator reference - uses 'ingress.value' instead of 'rule.value'
      # BUG 5: from_port and to_port are SWAPPED
      dynamic "ingress" {
        for_each = ingress.value.port_ranges
        iterator = port_range

        content {
          from_port   = port_range.value.to_port
          to_port     = port_range.value.from_port
          cidr_blocks = rule.value.cidrs
        }
      }
    }
  }

  # BUG 6: Conditional dynamic produces null when enable_egress is false
  # because var.egress_rules default is null, not []
  # The ternary with null causes issues: null is not iterable
  dynamic "egress" {
    for_each = var.enable_egress ? var.egress_rules : null
    iterator = egress_rule

    content {
      description = egress_rule.value.description
      from_port   = egress_rule.value.from_port
      to_port     = egress_rule.value.to_port
      protocol    = egress_rule.value.protocol
      # BUG 7: cidrs should be passed as a list but the access is wrong
      # This produces a nested list [[cidr1, cidr2]] instead of [cidr1, cidr2]
      cidr_blocks = [egress_rule.value.cidrs]
    }
  }

  tags = {
    Name        = "microservices-sg-${var.environment}"
    Environment = var.environment
    Team        = var.team
    ManagedBy   = "terraform"
  }
}

# Output to verify the rules created
output "security_group_id" {
  value = aws_security_group.microservices.id
}

output "ingress_rules_count" {
  description = "Should be 12 rules for 4 apps × 3 rule sets (with expanded port ranges)"
  value       = length(aws_security_group.microservices.ingress)
}

output "egress_rules_count" {
  description = "Should be 3 egress rules"
  value       = length(aws_security_group.microservices.egress)
}
