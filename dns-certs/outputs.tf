output "zone_id" {
  description = "Route 53 hosted zone ID."
  value       = local.zone_id
}

output "name_servers" {
  description = "Name servers of the created zone (set these at your registrar). Empty when the zone is looked up."
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : []
}

output "certificate_arns" {
  description = "Map of certificate short name to the ARN of the validated certificate."
  value       = { for k, v in aws_acm_certificate_validation.this : k => v.certificate_arn }
}
