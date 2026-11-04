output "address" {
  description = "Hostname of the database."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Database port."
  value       = aws_db_instance.this.port
}

output "identifier" {
  description = "Instance identifier, used as the DBInstanceIdentifier dimension of CloudWatch alarms."
  value       = aws_db_instance.this.identifier
}

output "arn" {
  description = "ARN of the instance."
  value       = aws_db_instance.this.arn
}

output "security_group_id" {
  description = "Security group of the database."
  value       = aws_security_group.this.id
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret that holds the generated master password."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
