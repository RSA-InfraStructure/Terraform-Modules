variable "name" {
  description = "Name prefix, e.g. rsa-prod."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the cache (private or isolated)."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups (for example the ECS tasks) allowed to connect on the Redis port."
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "Redis OSS engine version."
  type        = string
  default     = "7.1"
}

variable "node_type" {
  description = "Cache node type."
  type        = string
  default     = "cache.t4g.micro"
}

variable "num_cache_clusters" {
  description = "Number of nodes (1 = single node, 2+ = primary with replicas). Use 2+ with automatic failover for prod."
  type        = number
  default     = 1
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover. Requires num_cache_clusters >= 2."
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Spread nodes across AZs. Requires automatic failover."
  type        = bool
  default     = false
}

variable "port" {
  description = "Redis port."
  type        = number
  default     = 6379
}

variable "transit_encryption_enabled" {
  description = "Encrypt traffic in transit (clients must use TLS)."
  type        = bool
  default     = true
}

variable "snapshot_retention_days" {
  description = "Days to keep daily snapshots (0 disables)."
  type        = number
  default     = 0
}

variable "apply_immediately" {
  description = "Apply changes immediately instead of in the maintenance window."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
