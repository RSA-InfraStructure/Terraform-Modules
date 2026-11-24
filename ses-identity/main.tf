locals {
  mail_from_domain = "${var.mail_from_subdomain}.${var.domain}"
  create_dns       = var.route53_zone_id != null
  dmarc_value      = var.dmarc_rua == null ? "v=DMARC1; p=${var.dmarc_policy}" : "v=DMARC1; p=${var.dmarc_policy}; rua=mailto:${var.dmarc_rua}"
}

data "aws_region" "current" {}

################################################################################
# Domain identity with Easy DKIM (RSA 2048) and a custom MAIL FROM domain
################################################################################

resource "aws_sesv2_email_identity" "domain" {
  email_identity = var.domain

  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }

  tags = var.tags
}

resource "aws_sesv2_email_identity_mail_from_attributes" "domain" {
  email_identity         = aws_sesv2_email_identity.domain.email_identity
  mail_from_domain       = local.mail_from_domain
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
}

################################################################################
# Recipient identities (sandbox only). Each address must click the AWS link once.
################################################################################

resource "aws_sesv2_email_identity" "test_recipient" {
  for_each = toset(var.test_recipients)

  email_identity = each.value

  tags = var.tags
}

################################################################################
# DNS records (only when route53_zone_id is set)
################################################################################

resource "aws_route53_record" "dkim" {
  count = local.create_dns ? 3 : 0

  zone_id         = var.route53_zone_id
  name            = "${aws_sesv2_email_identity.domain.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.domain}"
  type            = "CNAME"
  ttl             = 300
  records         = ["${aws_sesv2_email_identity.domain.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
  allow_overwrite = true
}

resource "aws_route53_record" "mail_from_mx" {
  count = local.create_dns ? 1 : 0

  zone_id         = var.route53_zone_id
  name            = local.mail_from_domain
  type            = "MX"
  ttl             = 300
  records         = ["10 feedback-smtp.${data.aws_region.current.region}.amazonses.com"]
  allow_overwrite = true
}

resource "aws_route53_record" "mail_from_spf" {
  count = local.create_dns ? 1 : 0

  zone_id         = var.route53_zone_id
  name            = local.mail_from_domain
  type            = "TXT"
  ttl             = 300
  records         = ["v=spf1 include:amazonses.com ~all"]
  allow_overwrite = true
}

resource "aws_route53_record" "dmarc" {
  count = local.create_dns ? 1 : 0

  zone_id         = var.route53_zone_id
  name            = "_dmarc.${var.domain}"
  type            = "TXT"
  ttl             = 300
  records         = [local.dmarc_value]
  allow_overwrite = true
}
