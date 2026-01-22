

resource "aws_cloudwatch_log_group" "this" {
  name              = "/${var.name_prefix}/${var.environment}/ecs"
  retention_in_days = 30

  tags = {
    Name = "${var.name_prefix}-logs"
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-mod-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.name_prefix}-mod-cluster"
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs-sg-threatcomp"
  description = "ECS service SG for threatcomp"
  vpc_id      = var.vpc_id

  ingress {
    description     = "All TCP from ALB SG"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg-threatcomp"
  }
}

resource "aws_iam_role" "task_execution" {
  name = "${var.name_prefix}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_exec_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ssm_parameter" "this" {
  for_each = var.ssm_parameters

  name  = each.key
  type  = "SecureString"
  value = each.value

  tags = {
    Name = "${var.name_prefix}-ssm"
  }
}

resource "aws_iam_policy" "ssm_read" {
  count = length(var.ssm_parameters) > 0 ? 1 : 0

  name = "${var.name_prefix}-ecs-ssm-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameters", "ssm:GetParameter", "ssm:GetParametersByPath"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_read_attach" {
  count      = length(var.ssm_parameters) > 0 ? 1 : 0
  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.ssm_read[0].arn
}

locals {
  container_name = "${var.name_prefix}-app"
  image          = "${var.ecr_repo_url}:latest"

  secrets = [
    for k, _ in var.ssm_parameters : {
      name      = replace(k, "/${var.name_prefix}/${var.environment}/", "")
      valueFrom = k
    }
  ]
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name_prefix}-tf" # threatcomp-tf
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)

  execution_role_arn = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = local.image
      essential = true

      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      secrets = local.secrets
    }
  ])

  tags = {
    Name = "${var.name_prefix}-tf"
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  tags = {
    Name = "${var.name_prefix}-service"
  }

  depends_on = [aws_ecs_task_definition.this]
}