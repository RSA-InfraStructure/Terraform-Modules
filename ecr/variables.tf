variable "name" {
  description = "Name prefix, e.g. rsa. Repositories are named <name>/<repository>."
  type        = string
}

variable "repositories" {
  description = "Short names of the repositories to create, e.g. [\"api\", \"worker\"]."
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE. IMMUTABLE stops a tag (such as a git SHA) from being overwritten."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Scan images for vulnerabilities when pushed."
  type        = bool
  default     = true
}

variable "max_tagged_images" {
  description = "Number of most recent tagged images to keep per repository."
  type        = number
  default     = 20
}

variable "untagged_expiry_days" {
  description = "Days after which untagged images are deleted."
  type        = number
  default     = 7
}

variable "force_delete" {
  description = "Allow deleting repositories that still contain images."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
