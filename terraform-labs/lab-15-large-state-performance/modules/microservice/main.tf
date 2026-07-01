# Microservice module - called 20+ times with for_each
# BUG: Contains redundant data source lookups evaluated per instance

variable "service_name" { type = string }
variable "cpu" { type = number }
variable "memory" { type = number }
variable "port" { type = number }
variable "replicas" { type = number }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "ami_id" { type = string }
variable "secret_arn" { type = string }
variable "task_policy_json" { type = string }
variable "alb_arn" { type = string }
variable "tags" { type = map(string) }

# BUG: REDUNDANT data source - already fetched at root level
data "aws_availability_zones" "available" {
  state = "available"
}

# BUG: REDUNDANT - VPC ID is passed as variable but module re-fetches
data "aws_vpc" "current" {
  id = var.vpc_id
}

# BUG: REDUNDANT - fetches caller identity per module instance
data "aws_caller_identity" "current" {}

# BUG: REDUNDANT - region lookup per module instance
data "aws_region" "current" {}

# ECS Cluster (should be shared, not per-service)
resource "aws_ecs_cluster" "service" {
  name = "${var.service_name}-cluster"
  tags = var.tags
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.service_name}:latest"
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [{
        containerPort = var.port
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.service_name}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.service.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.replicas
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs.id]
  }

  tags = var.tags
}

resource "aws_security_group" "ecs" {
  name        = "${var.service_name}-ecs-sg"
  description = "Security group for ${var.service_name} ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.current.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.service_name}-ecs-sg" })
}

resource "aws_iam_role" "task" {
  name = "${var.service_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role" "execution" {
  name = "${var.service_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "task" {
  name   = "${var.service_name}-task-policy"
  role   = aws_iam_role.task.id
  policy = var.task_policy_json
}

resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 30
  tags              = var.tags
}

output "endpoint" {
  value = "${var.service_name}.internal.company.com"
}

output "cluster_arn" {
  value = aws_ecs_cluster.service.arn
}
