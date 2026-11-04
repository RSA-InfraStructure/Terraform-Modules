variable "name" {
  description = "Name prefix, e.g. rsa-staging."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_id" {
  description = "Private subnet for the instance. It needs a route to the SSM service (NAT gateway or VPC endpoints for ssm, ssmmessages and ec2messages)."
  type        = string
}

variable "instance_type" {
  description = "Instance type. t4g.nano is enough for port forwarding."
  type        = string
  default     = "t4g.nano"
}

variable "database_port" {
  description = "Database port the bastion forwards to."
  type        = number
  default     = 5432
}

variable "database_security_group_ids" {
  description = "Security groups of the databases the bastion may reach. Also add the bastion's own security group to their allowed list."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
