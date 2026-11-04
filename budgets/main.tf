locals {
  actual_thresholds = [50, 80, 100]
}

resource "aws_budgets_budget" "monthly" {
  name         = "${var.name}-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.target_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # The tag must be activated as a cost allocation tag in AWS Billing first.
  cost_filter {
    name   = "TagKeyValue"
    values = [format("user:%s$%s", var.tag_key, var.tag_value)]
  }

  dynamic "notification" {
    for_each = local.actual_thresholds

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.emails
    }
  }

  # Early warning: the month is forecast to pass the hard cap.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.cap_usd
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.emails
  }
}
