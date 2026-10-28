variable "zone_name" {
  description = "Domain of the hosted zone, e.g. example.com."
  type        = string
}

variable "create_zone" {
  description = "Create the hosted zone. Set false to look up an existing one by zone_name."
  type        = bool
  default     = true
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
  description = "Alias records (A and AAAA) pointing at an ALB or CloudFront, keyed by a short name."
  type = map(object({
    name                   = string
    target_dns_name        = string
    target_zone_id         = string
    evaluate_target_health = optional(bool, false)
  }))
  default = {}
}

variable "records" {
  description = "Plain DNS records (TXT, CNAME, MX and so on), keyed by a short name."
  type = map(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
