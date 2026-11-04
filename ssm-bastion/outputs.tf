output "instance_id" {
  description = "Instance ID. Use it as the target of the SSM port-forwarding session."
  value       = aws_instance.this.id
}

output "security_group_id" {
  description = "Security group of the bastion. Add it to the database's allowed_security_group_ids."
  value       = aws_security_group.this.id
}

output "role_arn" {
  description = "ARN of the instance role."
  value       = aws_iam_role.this.arn
}
