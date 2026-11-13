variable "name_prefix" {
  description = "Prefix for role names, e.g. rsa. Roles are named <name_prefix>-<role key>."
  type        = string
}

variable "create_oidc_provider" {
  description = "Create the GitHub OIDC identity provider. An account can have only one, so set false when it already exists (it is then looked up)."
  type        = bool
  default     = true
}

variable "roles" {
  description = <<-EOT
    Roles that GitHub Actions can assume, keyed by short name (for example "infra-staging").
    Each role trusts exactly one workflow context: either a GitHub environment or a branch. Set one of them, never both.
    The prod role should trust only the "prod" GitHub environment, so it cannot be assumed without that environment's approval.
  EOT
  type = map(object({
    github_repo          = string
    subject_prefix       = optional(string)
    environment          = optional(string)
    branch               = optional(string)
    policy_json          = optional(string)
    managed_policy_arns  = optional(list(string), [])
    max_session_duration = optional(number, 3600)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.roles) : can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", r.github_repo))])
    error_message = "github_repo must look like owner/repository, for example RSA-InfraStructure/infra."
  }

  validation {
    condition     = alltrue([for r in values(var.roles) : r.subject_prefix == null ? true : can(regex("^repo:[A-Za-z0-9_.-]+(@[0-9]+)?/[A-Za-z0-9_.-]+(@[0-9]+)?$", r.subject_prefix))])
    error_message = "subject_prefix must look like repo:owner/repository or repo:owner@123/repository@456 (GitHub immutable subject claims)."
  }

  validation {
    condition     = alltrue([for r in values(var.roles) : (r.environment != null) != (r.branch != null)])
    error_message = "Set exactly one of environment or branch on every role."
  }

  validation {
    condition     = alltrue([for r in values(var.roles) : r.max_session_duration >= 3600 && r.max_session_duration <= 43200])
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
