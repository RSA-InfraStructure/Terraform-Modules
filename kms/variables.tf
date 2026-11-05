variable "name" {
  description = "Alias name without the alias/ prefix, e.g. rsa-staging-data. Use one key per environment."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]{1,256}$", var.name)) && !startswith(var.name, "aws/")
    error_message = "name may contain letters, digits, /, _ and -, and must not start with aws/ (reserved by AWS)."
  }
}

variable "description" {
  description = "What the key protects, shown in the console."
  type        = string
  default     = "Application data and secrets"
}

variable "deletion_window_days" {
  description = "Days AWS waits before deleting the key after it is scheduled for deletion (7-30)."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_days >= 7 && var.deletion_window_days <= 30
    error_message = "deletion_window_days must be between 7 and 30."
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
