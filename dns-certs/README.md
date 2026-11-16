# dns-certs

Route 53 hosted zone (created or looked up), DNS-validated ACM certificates, alias records for ALB and CloudFront, and plain records (TXT, MX, CNAME).

## Example

```hcl
module "dns" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//dns-certs?ref=v0.1.0"

  zone_name = "example.com"

  certificates = {
    prod = { domain_name = "example.com", sans = ["*.example.com"] }
  }

  alias_records = {
    api = {
      name            = "api.example.com"
      target_dns_name = module.ecs_cluster.alb_dns_name
      target_zone_id  = module.ecs_cluster.alb_zone_id
    }
  }
}
```

## DNS hosted elsewhere (Cloudflare and others): `validation_mode = "external"`

No Route 53 zone is created. The certificate is created, and the DNS records you must add are returned in the `validation_records` output.

```hcl
module "dns" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//dns-certs?ref=dns-certs-v1.1.0"

  validation_mode     = "external"
  wait_for_validation = false # first apply: create the certificate only

  certificates = {
    main = { domain_name = "example.com", sans = ["*.example.com"] }
  }
}
```

1. Apply with `wait_for_validation = false`. Read `validation_records`.
2. Add the CNAME in your DNS provider (once; it stays for renewals). The apex and the wildcard share one record.
3. Set `wait_for_validation = true` and apply again. The certificate is then issued and can be attached to a load balancer.

`alias_records` and `records` need a Route 53 zone and are rejected in external mode.

## Notes

- A newly created zone needs its `name_servers` set at the registrar before certificate validation can succeed.
- Certificates are created in the caller's provider region. For CloudFront, call the module again with an AWS provider aliased to `us-east-1` and `create_zone = false`.
- CloudFront alias targets use the fixed zone ID `Z2FDTNDATAQYW2`.
