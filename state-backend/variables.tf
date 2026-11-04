variable "bucket_name" {
  description = "Globally unique name of the state bucket, e.g. rsa-staging-tfstate. One bucket per environment."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters: lower-case letters, digits, dots and hyphens, starting and ending with a letter or digit."
  }
}

variable "kms_alias" {
  description = "Name of the KMS key alias without the alias/ prefix. Defaults to bucket_name."
  type        = string
  default     = null

  validation {
    condition     = var.kms_alias == null || !startswith(var.kms_alias, "aws/")
    error_message = "kms_alias must not start with aws/ (reserved by AWS)."
  }
}

variable "kms_deletion_window_days" {
  description = "Days AWS waits before deleting the KMS key after it is scheduled for deletion (7-30)."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_days >= 7 && var.kms_deletion_window_days <= 30
    error_message = "kms_deletion_window_days must be between 7 and 30."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep old versions of state files, so an earlier state can be recovered."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 7
    error_message = "noncurrent_version_expiration_days must be at least 7."
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
