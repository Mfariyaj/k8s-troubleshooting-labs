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

# --- RDS Instance (being created) ---

resource "aws_db_subnet_group" "app" {
  name       = "app-db-subnets"
  subnet_ids = ["subnet-0abc123", "subnet-0def456"]

  tags = {
    Name = "App DB Subnet Group"
  }
}

resource "aws_security_group" "db" {
  name        = "app-db-sg"
  description = "Security group for app database"
  vpc_id      = "vpc-0abc123"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "app_db" {
  identifier     = "app-database-prod"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  allocated_storage = 50
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "appdb"
  username = "appadmin"
  password = "CHANGE_ME_USE_SECRETS_MANAGER"

  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az            = true
  skip_final_snapshot = true

  tags = {
    Name        = "app-database-prod"
    Environment = "production"
  }
}

# BUG: This data source tries to READ the RDS instance that is being CREATED above!
# Data sources are evaluated at PLAN TIME, before any resources exist.
# This will fail because "app-database-prod" doesn't exist yet.
data "aws_db_instance" "app_db" {
  db_instance_identifier = "app-database-prod"
}

# --- Lambda Function that needs the DB endpoint ---

resource "aws_iam_role" "lambda" {
  name = "app-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_function" "app" {
  function_name = "app-api-handler"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "lambda.zip"

  environment {
    variables = {
      # BUG: Using the data source endpoint instead of the resource attribute directly
      # This should be: aws_db_instance.app_db.endpoint
      DB_HOST     = data.aws_db_instance.app_db.endpoint
      DB_PORT     = data.aws_db_instance.app_db.port
      DB_NAME     = "appdb"
      DB_USER     = "appadmin"
      ENVIRONMENT = "production"
    }
  }

  tags = {
    Name        = "app-api-handler"
    Environment = "production"
  }
}

# Also using data source for the address (should use resource reference)
resource "aws_route53_record" "db" {
  zone_id = "Z1234567890ABC"
  name    = "db.internal.mycompany.com"
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_db_instance.app_db.address]
}

output "db_endpoint" {
  value = data.aws_db_instance.app_db.endpoint
}

output "lambda_function_arn" {
  value = aws_lambda_function.app.arn
}
