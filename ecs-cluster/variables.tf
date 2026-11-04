variable "name" {
  description = "Cluster name, e.g. rsa-staging."
  type        = string
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights. Adds cost, so it is off by default."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
