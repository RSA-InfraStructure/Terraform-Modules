variable "name" {
  description = "Name prefix, e.g. rsa-staging."
  type        = string
}

variable "emails" {
  description = "Email addresses subscribed to the alarm topic. Each person must confirm the subscription email."
  type        = list(string)
  default     = []
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB (alb module output). Null skips the load balancer alarms."
  type        = string
  default     = null
}

variable "target_group_arn_suffixes" {
  description = "Map of service name to target group ARN suffix (ecs-service output), for the unhealthy host alarms. Needs alb_arn_suffix."
  type        = map(string)
  default     = {}
}

variable "ecs_services" {
  description = "ECS services to watch for high CPU and memory, keyed by a short name."
  type = map(object({
    cluster_name = string
    service_name = string
  }))
  default = {}
}

variable "rds_instance_ids" {
  description = "RDS instance identifiers to watch for CPU, free storage and connections."
  type        = list(string)
  default     = []
}

variable "alb_5xx_threshold" {
  description = "ALB-generated 5xx responses in 5 minutes that trigger the alarm."
  type        = number
  default     = 10
}

variable "ecs_cpu_threshold" {
  description = "ECS service CPU percent that triggers the alarm."
  type        = number
  default     = 85
}

variable "ecs_memory_threshold" {
  description = "ECS service memory percent that triggers the alarm."
  type        = number
  default     = 85
}

variable "rds_cpu_threshold" {
  description = "RDS CPU percent that triggers the alarm."
  type        = number
  default     = 80
}

variable "rds_free_storage_gib_threshold" {
  description = "RDS free storage in GiB below which the alarm triggers."
  type        = number
  default     = 5
}

variable "rds_connections_threshold" {
  description = "RDS connection count that triggers the alarm."
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
