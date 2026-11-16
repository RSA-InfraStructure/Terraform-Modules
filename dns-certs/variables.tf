variable "zone_name" {
  description = "Domain of the hosted zone, e.g. example.com. Required when validation_mode is route53. Not used when validation_mode is external."
  type        = string
  default     = null

  validation {
    condition     = var.validation_mode == "external" || var.zone_name != null
    error_message = "zone_name is required when validation_mode is route53."
  }
}

variable "create_zone" {
  description = "Create the hosted zone. Set false to look up an existing one by zone_name. Ignored when validation_mode is external."
  type        = bool
  default     = true
}

variable "validation_mode" {
  description = <<-EOT
    How certificates are validated.
    route53 (default): validation records are created in a Route 53 zone (created or looked up).
    external: DNS is hosted elsewhere (for example Cloudflare). No Route 53 resources are created. The validation records are returned in the validation_records output for someone to add by hand once.
  EOT
  type        = string
  default     = "route53"

  validation {
    condition     = contains(["route53", "external"], var.validation_mode)
    error_message = "validation_mode must be route53 or external."
  }
}

variable "wait_for_validation" {
  description = "Only for validation_mode external: wait until the certificate is issued. Leave false on the first apply, add the validation record where your DNS lives, then set true. Always waits in route53 mode."
  type        = bool
  default     = false
}

variable "certificates" {
  description = "ACM certificates to create and DNS-validate, keyed by short name. Each lists a primary domain and optional extra names."
  type = map(object({
    domain_name = string
    sans        = optional(list(string), [])
  }))
  default = {}
}

variable "alias_records" {
  description = "Alias records (A and AAAA) pointing at an ALB or CloudFront, keyed by a short name. Only with validation_mode route53."
  type = map(object({
    name                   = string
    target_dns_name        = string
    target_zone_id         = string
    evaluate_target_health = optional(bool, false)
  }))
  default = {}

  validation {
    condition     = var.validation_mode == "route53" || length(var.alias_records) == 0
    error_message = "alias_records need a Route 53 zone: use validation_mode route53, or add the record where your DNS lives."
  }
}

variable "records" {
  description = "Plain DNS records (TXT, CNAME, MX and so on), keyed by a short name. Only with validation_mode route53."
  type = map(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  default = {}

  validation {
    condition     = var.validation_mode == "route53" || length(var.records) == 0
    error_message = "records need a Route 53 zone: use validation_mode route53, or add the record where your DNS lives."
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
