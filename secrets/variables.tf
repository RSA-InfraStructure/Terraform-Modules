variable "name_prefix" {
  description = "Prefix for secret names, e.g. rsa/staging. Secrets are named <name_prefix>/<key>."
  type        = string
}

variable "secrets" {
  description = "Secret containers to create, keyed by short name. Only the container is created; the value is set by a person outside Terraform."
  type = map(object({
    description             = optional(string, "")
    kms_key_id              = optional(string)
    recovery_window_in_days = optional(number, 30)
  }))
  default = {}

  validation {
    condition     = alltrue([for s in values(var.secrets) : s.recovery_window_in_days == 0 || (s.recovery_window_in_days >= 7 && s.recovery_window_in_days <= 30)])
    error_message = "recovery_window_in_days must be 0 (immediate deletion) or between 7 and 30."
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
