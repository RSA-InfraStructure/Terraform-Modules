variable "name" {
  description = "Budget name prefix, e.g. rsa-api."
  type        = string
}

variable "tag_key" {
  description = "Cost allocation tag to filter by: app (one budget per application) or env."
  type        = string
  default     = "app"
}

variable "tag_value" {
  description = "Value of the tag to filter by, e.g. api."
  type        = string
}

variable "target_usd" {
  description = "Monthly budget in USD. Alerts at 50%, 80% and 100% of it."
  type        = number
  default     = 200
}

variable "cap_usd" {
  description = "Hard cap in USD. A forecast alert fires when the forecast passes it."
  type        = number
  default     = 250
}

variable "emails" {
  description = "Email addresses that receive the alerts."
  type        = list(string)

  validation {
    condition     = length(var.emails) > 0
    error_message = "At least one email address is required."
  }
}
