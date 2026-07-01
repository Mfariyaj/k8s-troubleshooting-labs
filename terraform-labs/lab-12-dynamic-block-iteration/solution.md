## Solution: Dynamic Block Iteration

### Root Cause

Multiple issues with dynamic block iteration in the security group:

1. **Missing `flatten()`** — `flattened_rules` produces a list-of-lists, not a flat list
2. **`for_each` iterates over inner lists** — each element is a list, not a rule object
3. **Wrong iterator references** — `ingress.value` used instead of `rule.value` inside nested dynamic
4. **Nested dynamic block uses same name "ingress"** — can't nest a dynamic block with the same label
5. **`from_port` and `to_port` are swapped**
6. **`null` used in ternary for `for_each`** — `null` is not iterable; use `[]`
7. **`[egress_rule.value.cidrs]`** — wraps an already-list in another list

### Step-by-Step Fix

### Fixed Code (main.tf — locals)

```hcl
locals {
  # Fix 1: Add flatten() to produce a flat list of individual rules
  flattened_rules = flatten([
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
  ])
}
```

### Fixed Code (main.tf — security group)

```hcl
resource "aws_security_group" "microservices" {
  name        = "microservices-${var.environment}"
  description = "Security group for microservices platform - ${var.environment}"
  vpc_id      = var.vpc_id

  # Fix 2: for_each now iterates over a flat list of rule objects
  dynamic "ingress" {
    for_each = local.flattened_rules
    iterator = rule

    content {
      # Fix 3: rule.value is now a single rule object (not a list)
      description = rule.value.description
      protocol    = rule.value.protocol
      # Fix 4 & 5: Use correct port order; flatten port_ranges into first range
      from_port   = rule.value.port_ranges[0].from_port
      to_port     = rule.value.port_ranges[0].to_port
      cidr_blocks = rule.value.cidrs
    }
  }

  # Fix 6: Use [] instead of null when egress is disabled
  dynamic "egress" {
    for_each = var.enable_egress ? coalesce(var.egress_rules, []) : []
    iterator = egress_rule

    content {
      description = egress_rule.value.description
      from_port   = egress_rule.value.from_port
      to_port     = egress_rule.value.to_port
      protocol    = egress_rule.value.protocol
      # Fix 7: cidrs is already a list — don't wrap it again
      cidr_blocks = egress_rule.value.cidrs
    }
  }

  tags = {
    Name        = "microservices-sg-${var.environment}"
    Environment = var.environment
    Team        = var.team
    ManagedBy   = "terraform"
  }
}
```

### Fixed Code (variables.tf — egress_rules default)

```hcl
variable "egress_rules" {
  description = "Egress rules"
  type = list(object({
    description = string
    protocol    = string
    from_port   = number
    to_port     = number
    cidrs       = list(string)
  }))
  default = []  # Fix: use empty list instead of null
}
```

### Verification

```bash
terraform validate
terraform plan
# Verify expected rule counts in plan output
```
