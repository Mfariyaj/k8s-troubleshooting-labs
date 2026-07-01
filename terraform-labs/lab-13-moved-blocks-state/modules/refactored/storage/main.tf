# Refactored storage module - uses for_each instead of count

variable "buckets" {
  description = "Map of bucket configurations"
  type = map(object({
    versioning = bool
    encryption = string
  }))
}

variable "account_id" {
  description = "AWS account ID for unique naming"
  type        = string
}

resource "aws_s3_bucket" "data" {
  for_each = var.buckets

  bucket = "company-data-${each.key}-${var.account_id}"

  tags = {
    Name       = "data-${each.key}"
    Versioning = each.value.versioning
  }
}

resource "aws_s3_bucket_versioning" "data" {
  for_each = var.buckets

  bucket = aws_s3_bucket.data[each.key].id

  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Suspended"
  }
}

output "bucket_arns" {
  value = { for k, v in aws_s3_bucket.data : k => v.arn }
}
