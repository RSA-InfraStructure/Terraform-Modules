output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "ARN of the current task definition revision."
  value       = aws_ecs_task_definition.this.arn
}

output "security_group_id" {
  description = "Security group of the tasks. Allow it on databases or caches the service needs."
  value       = aws_security_group.this.id
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix, used as the TargetGroup dimension of CloudWatch alarms."
  value       = aws_lb_target_group.this.arn_suffix
}

output "log_group_name" {
  description = "CloudWatch log group of the service."
  value       = aws_cloudwatch_log_group.this.name
}

output "task_role_arn" {
  description = "ARN of the task role (what the application may do)."
  value       = aws_iam_role.task.arn
}

output "execution_role_arn" {
  description = "ARN of the task execution role."
  value       = aws_iam_role.execution.arn
}
