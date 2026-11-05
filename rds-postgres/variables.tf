variable "name" {
  description = "Name prefix and instance identifier, e.g. rsa-staging-db."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the database: the isolated subnets (at least two AZs)."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "A DB subnet group needs subnets in at least two Availability Zones."
  }
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect on the database port (the ECS services, the bastion)."
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "PostgreSQL version, for example 16 or 16.4. A major-only value follows the newest minor."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "Instance class. db.t4g.micro is the cheapest sensible size."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial storage in GiB (gp3)."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Storage autoscaling limit in GiB. Set 0 to turn autoscaling off."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Run a standby in a second AZ (doubles the instance cost). Use for prod only if the budget allows."
  type        = bool
  default     = false
}

variable "master_username" {
  description = "Master user name. The password is generated and kept in Secrets Manager by RDS; it is never an input."
  type        = string
  default     = "dbadmin"
}

variable "backup_retention_days" {
  description = "Days of automated backups (0 turns them off)."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Prevent the instance from being deleted."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on deletion. Keep false for anything with data."
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ARN for storage encryption. Null uses the AWS managed RDS key."
  type        = string
  default     = null
}

variable "master_user_secret_kms_key_id" {
  description = "KMS key ARN for the generated master password in Secrets Manager. Null uses the AWS managed Secrets Manager key."
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Apply changes immediately instead of in the maintenance window."
  type        = bool
  default     = false
}

variable "port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
