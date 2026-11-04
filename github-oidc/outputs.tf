output "provider_arn" {
  description = "ARN of the GitHub OIDC identity provider."
  value       = local.provider_arn
}

output "role_arns" {
  description = "Map of role short name to ARN. Use these as role-to-assume in the workflows."
  value       = { for k, r in aws_iam_role.this : k => r.arn }
}

output "role_names" {
  description = "Map of role short name to role name."
  value       = { for k, r in aws_iam_role.this : k => r.name }
}

output "subjects" {
  description = "The GitHub token subject each role trusts."
  value       = local.subjects
}
