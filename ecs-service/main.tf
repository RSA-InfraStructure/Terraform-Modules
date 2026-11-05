data "aws_region" "current" {}

locals {
  cluster_name = element(split("/", var.cluster_arn), 1)
  service_name = var.name

  container_health_check_command = coalesce(
    var.container_health_check_command,
    ["CMD-SHELL", "curl -fsS http://localhost:${var.container_port}${var.health_check_path} || exit 1"],
  )
}

################################################################################
# Logs
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

################################################################################
# Roles
################################################################################

data "aws_iam_policy_document" "tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Execution role: pulls the image, writes logs and fetches the secrets at start.
resource "aws_iam_role" "execution" {
  name               = "${var.name}-exec"
  assume_role_policy = data.aws_iam_policy_document.tasks_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "execution_secrets" {
  count = length(var.secrets) > 0 ? 1 : 0

  statement {
    sid       = "ReadOwnSecrets"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = values(var.secrets)
  }

  dynamic "statement" {
    for_each = var.secrets_kms_key_arn == null ? [] : [1]

    content {
      sid       = "DecryptSecrets"
      actions   = ["kms:Decrypt"]
      resources = [var.secrets_kms_key_arn]
    }
  }
}

resource "aws_iam_role_policy" "execution_secrets" {
  count = length(var.secrets) > 0 ? 1 : 0

  name   = "read-secrets"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution_secrets[0].json
}

# Task role: what the application code itself is allowed to do.
resource "aws_iam_role" "task" {
  name               = "${var.name}-task"
  assume_role_policy = data.aws_iam_policy_document.tasks_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy" "task" {
  count = var.task_role_policy_json == null ? 0 : 1

  name   = "app"
  role   = aws_iam_role.task.id
  policy = var.task_role_policy_json
}

################################################################################
# Task definition
################################################################################

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.architecture
  }

  container_definitions = jsonencode([
    {
      name      = var.name
      image     = var.image
      essential = true
      cpu       = var.cpu
      memory    = var.memory

      portMappings = [{
        containerPort = var.container_port
        protocol      = "tcp"
      }]

      environment = [for k, v in var.environment : { name = k, value = v }]
      secrets     = [for k, arn in var.secrets : { name = k, valueFrom = arn }]

      readonlyRootFilesystem = var.readonly_root_filesystem

      healthCheck = {
        command     = local.container_health_check_command
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = var.health_check_grace_period_seconds
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

  tags = var.tags
}

################################################################################
# Load balancer wiring
################################################################################

resource "aws_lb_target_group" "this" {
  name                 = var.name
  port                 = var.container_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = var.health_check_path
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }

  tags = var.tags
}

################################################################################
# Network access
################################################################################

resource "aws_security_group" "this" {
  name        = "${var.name}-svc"
  description = "Tasks of ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-svc" })
}

resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id            = aws_security_group.this.id
  description                  = "App port from the load balancer"
  referenced_security_group_id = var.alb_security_group_id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
}

# Tasks need outbound access to pull images and fetch secrets, unless VPC
# endpoints are used. Narrow egress_cidrs to restrict it.
#trivy:ignore:AVD-AWS-0104
resource "aws_vpc_security_group_egress_rule" "out" {
  for_each = toset(var.egress_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "Outbound"
  cidr_ipv4         = each.value
  ip_protocol       = "-1"
}

################################################################################
# Service
################################################################################

# Default: Terraform owns the running image (task_definition follows the plan).
resource "aws_ecs_service" "managed" {
  count = var.image_managed_by_pipeline ? 0 : 1

  name            = var.name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = var.use_spot ? "FARGATE_SPOT" : "FARGATE"
    weight            = 1
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.name
    container_port   = var.container_port
  }

  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  propagate_tags                     = "SERVICE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(var.tags, { Name = var.name })

  depends_on = [aws_lb_listener_rule.this]
}

# image_managed_by_pipeline = true: the app pipeline registers new task
# definition revisions and updates the service. Terraform creates the service
# and its first revision, then leaves task_definition alone so a later apply
# never reverts a deployment. It still manages everything else on the service.
resource "aws_ecs_service" "pipeline" {
  count = var.image_managed_by_pipeline ? 1 : 0

  name            = var.name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = var.use_spot ? "FARGATE_SPOT" : "FARGATE"
    weight            = 1
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.name
    container_port   = var.container_port
  }

  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  propagate_tags                     = "SERVICE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(var.tags, { Name = var.name })

  depends_on = [aws_lb_listener_rule.this]

  lifecycle {
    ignore_changes = [task_definition]
  }
}

################################################################################
# Autoscaling (optional)
################################################################################

resource "aws_appautoscaling_target" "this" {
  count = var.enable_autoscaling ? 1 : 0

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${local.cluster_name}/${local.service_name}"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity

  depends_on = [aws_ecs_service.managed, aws_ecs_service.pipeline]
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.name}-cpu"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  resource_id        = aws_appautoscaling_target.this[0].resource_id

  target_tracking_scaling_policy_configuration {
    target_value = var.cpu_target_percent

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
