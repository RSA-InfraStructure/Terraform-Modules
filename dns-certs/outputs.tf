output "zone_id" {
  description = "Route 53 hosted zone ID. Null when validation_mode is external."
  value       = local.zone_id
}

output "name_servers" {
  description = "Name servers of the created zone (set these at your registrar). Empty when the zone is looked up or validation_mode is external."
  value       = local.route53 && var.create_zone ? aws_route53_zone.this[0].name_servers : []
}

output "certificate_arns" {
  description = "Map of certificate short name to the certificate ARN. In external mode the certificate may still be pending until the validation record exists and wait_for_validation is true."
  value       = { for k, c in aws_acm_certificate.this : k => try(aws_acm_certificate_validation.this[k].certificate_arn, c.arn) }
}

output "validation_records" {
  description = "DNS validation records for each certificate name (CNAME name, type and value). In external mode, add these where your DNS lives. Names that share one certificate can return the same record."
  value       = local.validation_records
}
