# ses-identity

Amazon SES sending identity for one domain: Easy DKIM (RSA 2048), a custom MAIL FROM domain so SPF aligns, optional recipient identities for the SES sandbox, and the DNS records (DKIM CNAMEs, MAIL FROM MX and SPF, DMARC) in a Route 53 zone.

Sending only. It creates no configuration set, no bounce or complaint topic and no alarms. Add those in a later version if needed.

## Example

```hcl
module "ses" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//ses-identity?ref=ses-identity-v1.0.0"

  domain          = "mail.example.com"
  route53_zone_id = "Z0000000000EXAMPLE"

  dmarc_policy = "none"

  # Sandbox only: addresses that may receive mail while the account has no production access.
  test_recipients = ["tester@example.com"]

  tags = { app = "demo", env = "dev" }
}

data "aws_iam_policy_document" "send" {
  statement {
    actions   = ["ses:SendEmail"]
    resources = [module.ses.identity_arn]

    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = ["no-reply@mail.example.com"]
    }
  }
}
```

## Inputs

| Name | Default | Purpose |
|---|---|---|
| `domain` | required | Sending domain |
| `mail_from_subdomain` | `bounce` | MAIL FROM label (`bounce.<domain>`) |
| `route53_zone_id` | `null` | Zone for the records. Null creates none; use the `dns_records` output |
| `dmarc_policy` | `none` | `none`, `quarantine` or `reject` |
| `dmarc_rua` | `null` | Aggregate report address. Null omits `rua` |
| `test_recipients` | `[]` | Verified recipient addresses (sandbox) |
| `tags` | `{}` | Tags |

## Outputs
`identity_arn`, `domain`, `mail_from_domain`, `test_recipient_arns`, `dns_records`.

## Notes
- The domain becomes verified once the DKIM records resolve (minutes, up to 72 hours). Terraform does not wait for it.
- Each test recipient gets an email from AWS with a link. The address is verified only after the person clicks it.
- A new account is in the SES sandbox: verified recipients only, 200 messages per day, 1 per second. Production access is a request in the SES console, not a Terraform resource.
- Move `dmarc_policy` from `none` to `quarantine` only after reviewing that legitimate mail passes.
- This repository is public. Never put real recipient addresses or domains in it; pass them from the consuming stack.
