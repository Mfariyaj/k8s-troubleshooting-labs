provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "app_data" {
  bucket = "mycompany-app-data-prod-2024"

  tags = {
    Environment = "production"
    Application = "data-pipeline"
  }
}

resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
