output "topic_arn" {
  description = "ARN of the alarm topic. Add it as an action to other alarms if needed."
  value       = aws_sns_topic.this.arn
}
