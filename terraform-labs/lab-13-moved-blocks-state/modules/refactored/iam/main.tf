# Refactored IAM module - uses for_each instead of count

variable "roles" {
  description = "Map of IAM role configurations"
  type = map(object({
    policy_arns = list(string)
  }))
}

resource "aws_iam_role" "service" {
  for_each = var.roles

  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = each.key
  }
}

resource "aws_iam_role_policy_attachment" "service" {
  for_each = { for role_name, role_config in var.roles :
    role_name => role_config.policy_arns[0]
  }

  role       = aws_iam_role.service[each.key].name
  policy_arn = each.value
}

output "role_arns" {
  value = { for k, v in aws_iam_role.service : k => v.arn }
}
