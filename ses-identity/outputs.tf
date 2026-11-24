output "identity_arn" {
  description = "ARN of the sending domain identity. Use it as the Resource of the send policy."
  value       = aws_sesv2_email_identity.domain.arn
}

output "domain" {
  description = "The verified sending domain."
  value       = var.domain
}

output "mail_from_domain" {
  description = "Custom MAIL FROM domain."
  value       = local.mail_from_domain
}

output "test_recipient_arns" {
  description = "Map of recipient address to identity ARN."
  value       = { for k, i in aws_sesv2_email_identity.test_recipient : k => i.arn }
}

output "dns_records" {
  description = "The DNS records the domain needs (name, type, value). Add them by hand when route53_zone_id is null."
  value = concat(
    [for t in aws_sesv2_email_identity.domain.dkim_signing_attributes[0].tokens : {
      name  = "${t}._domainkey.${var.domain}"
      type  = "CNAME"
      value = "${t}.dkim.amazonses.com"
    }],
    [
      {
        name  = local.mail_from_domain
        type  = "MX"
        value = "10 feedback-smtp.${data.aws_region.current.region}.amazonses.com"
      },
      {
        name  = local.mail_from_domain
        type  = "TXT"
        value = "v=spf1 include:amazonses.com ~all"
      },
      {
        name  = "_dmarc.${var.domain}"
        type  = "TXT"
        value = local.dmarc_value
      },
    ],
  )
}
