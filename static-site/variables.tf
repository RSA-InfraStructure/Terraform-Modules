variable "name" {
  description = "Name prefix, e.g. rsa-prod-web. Used in the bucket name and CloudFront resources."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "aliases" {
  description = "Custom domain names for the distribution (requires certificate_arn)."
  type        = list(string)
  default     = []
}

variable "certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for the aliases. Leave null to use the default CloudFront domain."
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "Object served at the root path."
  type        = string
  default     = "index.html"
}

variable "spa_fallback" {
  description = "Return index.html for 403/404 responses so client-side routing works in a single-page app."
  type        = bool
  default     = true
}

variable "price_class" {
  description = "CloudFront price class: PriceClass_100, PriceClass_200 or PriceClass_All."
  type        = string
  default     = "PriceClass_100"
}

variable "web_acl_arn" {
  description = "Optional WAFv2 web ACL ARN (must be a CLOUDFRONT-scope ACL in us-east-1)."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Allow destroying the bucket while it still contains objects."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
