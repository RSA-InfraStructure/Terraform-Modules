output "secret_arns" {
  description = "Map of secret short name to ARN. Pass these to ecs-service in its secrets input."
  value       = { for k, s in aws_secretsmanager_secret.this : k => s.arn }
}

output "secret_names" {
  description = "Map of secret short name to full name."
  value       = { for k, s in aws_secretsmanager_secret.this : k => s.name }
}
