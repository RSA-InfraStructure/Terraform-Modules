variable "domain" {
  description = "Sending domain to verify in SES, for example mail.example.com. Mail is sent from addresses on this domain."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9]([a-z0-9-]*[a-z0-9])?\\.)+[a-z]{2,}$", var.domain))
    error_message = "domain must be a lower-case DNS name such as mail.example.com."
  }
}

variable "mail_from_subdomain" {
  description = "Label for the custom MAIL FROM domain (<label>.<domain>). It makes SPF align with the sending domain."
  type        = string
  default     = "bounce"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.mail_from_subdomain))
    error_message = "mail_from_subdomain must be a single lower-case DNS label."
  }
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID that holds the sending domain. Null creates no DNS records; add the ones in the dns_records output where your DNS lives."
  type        = string
  default     = null
}

variable "dmarc_policy" {
  description = "DMARC policy: none (monitor), quarantine or reject. Start with none and tighten after reviewing results."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "quarantine", "reject"], var.dmarc_policy)
    error_message = "dmarc_policy must be none, quarantine or reject."
  }
}

variable "dmarc_rua" {
  description = "Address for DMARC aggregate reports. Null leaves the rua tag out (no reports)."
  type        = string
  default     = null
}

variable "test_recipients" {
  description = "Email addresses to verify as recipients. Needed only while the account is in the SES sandbox, which can send only to verified addresses. Each address receives a confirmation link from AWS."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for a in var.test_recipients : can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", a))])
    error_message = "Every test recipient must be an email address."
  }
}

variable "tags" {
  description = "Tags added to every taggable resource."
  type        = map(string)
  default     = {}
}
