################################################################################
# Hosted zone
################################################################################

resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name = var.zone_name

  tags = merge(var.tags, { Name = var.zone_name })
}

data "aws_route53_zone" "existing" {
  count = var.create_zone ? 0 : 1

  name         = var.zone_name
  private_zone = false
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

################################################################################
# Certificates (DNS validated)
#
# The certificate is created in the provider region of the caller. For CloudFront
# call this module (or a second instance of it) with a us-east-1 provider.
################################################################################

resource "aws_acm_certificate" "this" {
  for_each = var.certificates

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.sans
  validation_method         = "DNS"

  tags = merge(var.tags, { Name = each.value.domain_name })

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  validation_records = merge([
    for cert_key, cert in aws_acm_certificate.this : {
      for dvo in cert.domain_validation_options :
      "${cert_key}|${dvo.domain_name}" => {
        name   = dvo.resource_record_name
        type   = dvo.resource_record_type
        record = dvo.resource_record_value
      }
    }
  ]...)
}

resource "aws_route53_record" "validation" {
  for_each = local.validation_records

  zone_id         = local.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  for_each = aws_acm_certificate.this

  certificate_arn = each.value.arn
  validation_record_fqdns = [
    for k, r in aws_route53_record.validation : r.fqdn if startswith(k, "${each.key}|")
  ]
}

################################################################################
# Records
################################################################################

resource "aws_route53_record" "alias_a" {
  for_each = var.alias_records

  zone_id = local.zone_id
  name    = each.value.name
  type    = "A"

  alias {
    name                   = each.value.target_dns_name
    zone_id                = each.value.target_zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}

resource "aws_route53_record" "alias_aaaa" {
  for_each = var.alias_records

  zone_id = local.zone_id
  name    = each.value.name
  type    = "AAAA"

  alias {
    name                   = each.value.target_dns_name
    zone_id                = each.value.target_zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}

resource "aws_route53_record" "plain" {
  for_each = var.records

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}
