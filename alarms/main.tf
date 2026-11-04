data "aws_caller_identity" "current" {}

################################################################################
# Notification topic
################################################################################

# A customer managed key is needed because CloudWatch cannot publish to a topic
# encrypted with the AWS managed SNS key.
data "aws_iam_policy_document" "topic_key" {
  statement {
    sid       = "EnableIamPolicies"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowCloudWatchToPublish"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey*"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_kms_key" "topic" {
  description         = "Encrypts the ${var.name} alarm topic"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.topic_key.json

  tags = merge(var.tags, { Name = "${var.name}-alarms" })
}

resource "aws_kms_alias" "topic" {
  name          = "alias/${var.name}-alarms"
  target_key_id = aws_kms_key.topic.key_id
}

resource "aws_sns_topic" "this" {
  name              = "${var.name}-alarms"
  kms_master_key_id = aws_kms_key.topic.arn

  tags = merge(var.tags, { Name = "${var.name}-alarms" })
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.emails)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}

################################################################################
# Load balancer
################################################################################

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.alb_arn_suffix == null ? 0 : 1

  alarm_name          = "${var.name}-alb-5xx"
  alarm_description   = "The load balancer itself returned 5xx errors"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.this.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  for_each = var.alb_arn_suffix == null ? {} : var.target_group_arn_suffixes

  alarm_name          = "${var.name}-${each.key}-unhealthy"
  alarm_description   = "${each.key} has unhealthy targets"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.this.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = each.value
  }

  tags = var.tags
}

################################################################################
# ECS services
################################################################################

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  for_each = var.ecs_services

  alarm_name          = "${var.name}-${each.key}-cpu"
  alarm_description   = "${each.key} CPU is high"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.ecs_cpu_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.this.arn]

  dimensions = {
    ClusterName = each.value.cluster_name
    ServiceName = each.value.service_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  for_each = var.ecs_services

  alarm_name          = "${var.name}-${each.key}-memory"
  alarm_description   = "${each.key} memory is high"
  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.ecs_memory_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.this.arn]

  dimensions = {
    ClusterName = each.value.cluster_name
    ServiceName = each.value.service_name
  }

  tags = var.tags
}

################################################################################
# RDS
################################################################################

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  for_each = toset(var.rds_instance_ids)

  alarm_name          = "${var.name}-${each.value}-cpu"
  alarm_description   = "${each.value} CPU is high"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.rds_cpu_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.this.arn]

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  for_each = toset(var.rds_instance_ids)

  alarm_name          = "${var.name}-${each.value}-free-storage"
  alarm_description   = "${each.value} is running out of storage"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Minimum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.rds_free_storage_gib_threshold * 1073741824
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = [aws_sns_topic.this.arn]

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  for_each = toset(var.rds_instance_ids)

  alarm_name          = "${var.name}-${each.value}-connections"
  alarm_description   = "${each.value} has many connections"
  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.rds_connections_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.this.arn]

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  tags = var.tags
}
