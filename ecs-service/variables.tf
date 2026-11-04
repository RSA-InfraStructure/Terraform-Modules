variable "name" {
  description = "Service name, e.g. rsa-staging-api. Used for the service, task, roles and log group."
  type        = string

  validation {
    condition     = length(var.name) <= 32
    error_message = "name must be 32 characters or fewer (it is also the target group name)."
  }
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster (from the ecs-cluster module)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the tasks. Private subnets with NAT, or public subnets with assign_public_ip."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Give tasks a public IP. Needed only when the tasks run in public subnets without a NAT gateway or endpoints."
  type        = bool
  default     = false
}

variable "image" {
  description = "Full image reference with an immutable tag (git SHA) or digest, e.g. 123456789012.dkr.ecr.us-east-2.amazonaws.com/rsa/api:3f9c2ab."
  type        = string

  validation {
    condition     = !endswith(var.image, ":latest") && (can(regex(":[^/]+$", var.image)) || can(regex("@sha256:", var.image)))
    error_message = "image must have an explicit tag or digest and must not use the latest tag."
  }
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
}

variable "cpu" {
  description = "Task CPU units (256, 512, 1024, 2048, 4096...). Always set; there is no unlimited option."
  type        = number

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096, 8192, 16384], var.cpu)
    error_message = "cpu must be a valid Fargate size: 256, 512, 1024, 2048, 4096, 8192 or 16384."
  }
}

variable "memory" {
  description = "Task memory in MiB. Must be a valid Fargate combination for the chosen cpu."
  type        = number

  validation {
    condition     = var.memory >= 512
    error_message = "memory must be at least 512 MiB."
  }
}

variable "architecture" {
  description = "CPU architecture: ARM64 (Graviton, cheaper) or X86_64. The image must match."
  type        = string
  default     = "ARM64"

  validation {
    condition     = contains(["ARM64", "X86_64"], var.architecture)
    error_message = "architecture must be ARM64 or X86_64."
  }
}

variable "desired_count" {
  description = "Number of tasks."
  type        = number
  default     = 1
}

variable "use_spot" {
  description = "Run on Fargate Spot (about 70% cheaper, can be interrupted). Suitable for staging and stateless workers."
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "HTTP path that returns 200 only when the service and its dependencies are ready."
  type        = string
  default     = "/health"
}

variable "health_check_grace_period_seconds" {
  description = "Seconds ECS ignores failed load balancer health checks after a task starts."
  type        = number
  default     = 60
}

variable "container_health_check_command" {
  description = "Container health check command. Default uses curl, which must exist in the image; override if it does not."
  type        = list(string)
  default     = null
}

variable "environment" {
  description = "Plain, non-secret environment variables."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of environment variable name to Secrets Manager secret ARN. Values are injected at start, never stored in the task definition."
  type        = map(string)
  default     = {}
}

variable "secrets_kms_key_arn" {
  description = "KMS key ARN if the secrets use a customer managed key. Null for the AWS managed key."
  type        = string
  default     = null
}

variable "task_role_policy_json" {
  description = "IAM policy JSON for what the application itself may do (for example read an S3 bucket). Null for none."
  type        = string
  default     = null
}

variable "readonly_root_filesystem" {
  description = "Mount the container root filesystem read-only. Safer, but the app must not write to it."
  type        = bool
  default     = false
}

# Listener rule
variable "listener_arn" {
  description = "HTTPS listener ARN of the shared ALB."
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group of the ALB. The service accepts traffic only from it."
  type        = string
}

variable "host_headers" {
  description = "Host names routed to this service, e.g. [\"api.example.com\"]."
  type        = list(string)
}

variable "listener_rule_priority" {
  description = "Priority of the listener rule. Must be unique on the listener."
  type        = number
}

variable "egress_cidrs" {
  description = "CIDRs the tasks may reach. Default is the internet (needed to pull images and call external APIs unless you use VPC endpoints)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Scaling
variable "enable_autoscaling" {
  description = "Scale the number of tasks on average CPU."
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum tasks when autoscaling is on."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum tasks when autoscaling is on."
  type        = number
  default     = 2
}

variable "cpu_target_percent" {
  description = "Target average CPU for autoscaling."
  type        = number
  default     = 70
}

variable "log_retention_days" {
  description = "CloudWatch log retention. 7-14 days by default to keep cost down."
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
