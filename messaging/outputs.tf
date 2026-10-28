output "queue_urls" {
  description = "Map of queue short name to URL."
  value       = { for k, q in aws_sqs_queue.this : k => q.id }
}

output "queue_arns" {
  description = "Map of queue short name to ARN."
  value       = { for k, q in aws_sqs_queue.this : k => q.arn }
}

output "dlq_arns" {
  description = "Map of queue short name to its dead-letter queue ARN."
  value       = { for k, q in aws_sqs_queue.dlq : k => q.arn }
}

output "topic_arns" {
  description = "Map of topic short name to ARN."
  value       = { for k, t in aws_sns_topic.this : k => t.arn }
}
