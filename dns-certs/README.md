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

## Notes

- A newly created zone needs its `name_servers` set at the registrar before certificate validation can succeed.
- Certificates are created in the caller's provider region. For CloudFront, call the module again with an AWS provider aliased to `us-east-1` and `create_zone = false`.
- CloudFront alias targets use the fixed zone ID `Z2FDTNDATAQYW2`.
