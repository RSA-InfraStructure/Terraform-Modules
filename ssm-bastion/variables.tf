variable "name" {
  description = "Name prefix, e.g. rsa-staging."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_id" {
  description = "Subnet for the instance. It needs a route to the SSM service: a NAT gateway or VPC endpoints for ssm, ssmmessages and ec2messages (private subnet), or an internet gateway route with associate_public_ip_address = true (public subnet)."
  type        = string
}

variable "associate_public_ip_address" {
  description = "Give the instance a public IPv4 address so it reaches SSM through an internet gateway in a public subnet, without NAT or VPC endpoints. The security group still has no inbound rules. Costs about 3.65 USD a month for the address."
  type        = bool
  default     = false
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
