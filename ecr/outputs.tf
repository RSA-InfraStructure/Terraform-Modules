output "repository_urls" {
  description = "Map of repository short name to its URL."
  value       = { for k, r in aws_ecr_repository.this : k => r.repository_url }
}

output "repository_arns" {
  description = "Map of repository short name to its ARN."
  value       = { for k, r in aws_ecr_repository.this : k => r.arn }
}

output "repository_names" {
  description = "Map of repository short name to its full name."
  value       = { for k, r in aws_ecr_repository.this : k => r.name }
}
