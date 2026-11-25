resource "aws_budgets_budget" "this" {
  name         = "${var.name}-${var.budget_suffix}-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Filter by AWS service name, e.g. "Amazon Simple Email Service". No cost allocation tag is needed.
  cost_filter {
    name   = "Service"
    values = [var.service]
  }

  dynamic "notification" {
    for_each = var.actual_thresholds

    content {
      comparison_operator       = "GREATER_THAN"
      threshold                 = notification.value
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_sns_topic_arns = var.sns_topic_arns
    }
  }

  dynamic "notification" {
    for_each = var.forecast_thresholds

    content {
      comparison_operator       = "GREATER_THAN"
      threshold                 = notification.value
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_sns_topic_arns = var.sns_topic_arns
    }
  }
}
