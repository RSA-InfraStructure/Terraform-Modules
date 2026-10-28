variable "name" {
  description = "Name prefix for all resources, e.g. rsa-prod."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC. Must be a /16 to /20 so it can be split into subnet tiers."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && tonumber(split("/", var.vpc_cidr)[1]) <= 20
    error_message = "vpc_cidr must be a valid CIDR with a prefix length of /20 or larger (e.g. /16)."
  }
}

variable "az_count" {
  description = "Number of Availability Zones to use (2 or 3)."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "subnet_newbits" {
  description = "Extra prefix bits added to vpc_cidr for each subnet (4 turns a /16 into /20 subnets). 16 slots exist: 0-3 public, 4-7 private, 8-11 isolated."
  type        = number
  default     = 4
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) so private subnets can reach the internet. Leave false to save cost (e.g. Fargate in public subnets)."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ (cheaper, not AZ-resilient). Only used when enable_nat_gateway is true."
  type        = bool
  default     = true
}

variable "enable_s3_gateway_endpoint" {
  description = "Create the free S3 gateway endpoint on all route tables."
  type        = bool
  default     = true
}

variable "interface_endpoints" {
  description = "Short service names to create interface VPC endpoints for in the private subnets, e.g. [\"ecr.api\", \"ecr.dkr\", \"logs\", \"secretsmanager\", \"ssm\"]. Each costs roughly $7/AZ/month."
  type        = list(string)
  default     = []
}

variable "enable_flow_logs" {
  description = "Send VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Retention in days for the flow log group."
  type        = number
  default     = 14
}

variable "flow_logs_traffic_type" {
  description = "Traffic type captured by flow logs: ACCEPT, REJECT or ALL."
  type        = string
  default     = "REJECT"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "flow_logs_traffic_type must be ACCEPT, REJECT or ALL."
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
