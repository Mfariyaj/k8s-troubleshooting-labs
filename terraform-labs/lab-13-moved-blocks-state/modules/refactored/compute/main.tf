# Refactored compute module - uses for_each instead of count

variable "instance_names" {
  description = "Map of instance configurations"
  type = map(object({
    instance_type = string
    subnet_id     = string
  }))
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

resource "aws_instance" "web" {
  for_each = var.instance_names

  ami           = var.ami_id
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id

  tags = merge(var.tags, {
    Name = "web-${each.key}"
  })
}

output "instance_ids" {
  value = { for k, v in aws_instance.web : k => v.id }
}
