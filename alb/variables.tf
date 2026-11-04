variable "name" {
  description = "Load balancer name, e.g. rsa-staging. Maximum 32 characters."
  type        = string

  validation {
    condition     = length(var.name) <= 32
    error_message = "name must be 32 characters or fewer (AWS limit for load balancer names)."
  }
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR of the VPC. The load balancer may only send traffic to targets inside it."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the load balancer: public subnets (at least two AZs) for an internet-facing ALB."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "An ALB needs subnets in at least two Availability Zones."
  }
}

variable "certificate_arn" {
  description = "ACM certificate ARN (same region as the ALB) for the HTTPS listener."
  type        = string
}

variable "internal" {
  description = "Create an internal load balancer instead of an internet-facing one."
  type        = bool
  default     = false
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs allowed to reach ports 80 and 443. Default is the whole internet."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssl_policy" {
  description = "TLS policy of the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "idle_timeout" {
  description = "Idle timeout in seconds."
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "Protect the load balancer from deletion. Turn off only for throwaway environments."
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs. Leave null to skip (saves cost)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
