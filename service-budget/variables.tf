variable "name" {
  description = "Budget name prefix, e.g. rsa-dev."
  type        = string
}

variable "budget_suffix" {
  description = "Budget name suffix, e.g. ses. The budget is named <name>-<suffix>-monthly."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.budget_suffix))
    error_message = "budget_suffix must be lower-case letters, digits and hyphens."
  }
}

variable "service" {
  description = "AWS service name exactly as Cost Explorer shows it, e.g. Amazon Simple Email Service."
  type        = string

  validation {
    condition     = length(var.service) > 0
    error_message = "service must not be empty."
  }
}

variable "limit_usd" {
  description = "Monthly limit in USD."
  type        = number

  validation {
    condition     = var.limit_usd > 0
    error_message = "limit_usd must be greater than 0."
  }
}

variable "actual_thresholds" {
  description = "Alert when actual spend passes these percentages of the limit."
  type        = list(number)
  default     = [80, 100]
}

variable "forecast_thresholds" {
  description = "Alert when forecast spend passes these percentages of the limit."
  type        = list(number)
  default     = [100]
}

variable "sns_topic_arns" {
  description = "SNS topics that receive the alerts. The topic policy must allow budgets.amazonaws.com to publish (alarms module: allow_budgets_publish), and a KMS key policy too if the topic is encrypted."
  type        = list(string)

  validation {
    condition     = length(var.sns_topic_arns) > 0
    error_message = "At least one SNS topic ARN is required."
  }
}
