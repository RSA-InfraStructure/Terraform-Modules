variable "name" {
  description = "Name prefix, e.g. rsa-prod."
  type        = string
}

variable "queues" {
  description = "Queues to create, keyed by short name. Each gets an optional dead-letter queue."
  type = map(object({
    visibility_timeout_seconds = optional(number, 30)
    message_retention_seconds  = optional(number, 345600)
    delay_seconds              = optional(number, 0)
    receive_wait_time_seconds  = optional(number, 20)
    fifo                       = optional(bool, false)
    enable_dlq                 = optional(bool, true)
    max_receive_count          = optional(number, 5)
    dlq_retention_seconds      = optional(number, 1209600)
  }))
  default = {}
}

variable "topics" {
  description = "SNS topics to create, keyed by short name."
  type = map(object({
    fifo = optional(bool, false)
  }))
  default = {}
}

variable "subscriptions" {
  description = "Topic to queue subscriptions. Each entry names a topic key and a queue key from the maps above."
  type = list(object({
    topic         = string
    queue         = string
    raw_delivery  = optional(bool, true)
    filter_policy = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
