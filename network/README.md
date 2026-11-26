# network

VPC with three subnet tiers across 2-3 AZs.

| Tier | Route to internet | Use for |
|---|---|---|
| public | Internet gateway | ALB (and Fargate tasks when NAT is disabled) |
| private | NAT gateway, only if `enable_nat_gateway = true` | Redis, tasks behind NAT |
| isolated | none | RDS |

Subnets are carved from `vpc_cidr` with `cidrsubnet`: slots 0-3 public, 4-7 private, 8-11 isolated (a /16 with `subnet_newbits = 4` gives /20 subnets).

## Cost toggles

- `enable_nat_gateway` (default `false`): NAT is the biggest network cost (~$32/month each plus data).
- `single_nat_gateway` (default `true`): one shared NAT instead of one per AZ.
- `nat_eip_allocation_ids` (default `[]`): reuse Elastic IPs created outside the module, one per NAT. With the default the module creates and owns the EIPs, and a NAT or module rebuild changes the public IP. Pass external IDs (EIPs with `prevent_destroy`) when the IP must stay fixed, for example for a third-party allow-list. Needs `ec2:DescribeAddresses` to read the public IP. Changing from module-owned to external IDs replaces the NAT gateway and changes the IP once.
- `interface_endpoints` (default `[]`): each endpoint is roughly $7/AZ/month.
- The S3 gateway endpoint is free and on by default.

## Example

```hcl
module "network" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//network?ref=network-v1.1.0"

  name     = "rsa-staging"
  vpc_cidr = "10.10.0.0/16"
  az_count = 2

  enable_nat_gateway = false

  tags = {
    env        = "staging"
    managed-by = "terraform"
  }
}
```

## Notes

- Public subnets do not auto-assign public IPs; set `assign_public_ip` on the ECS service instead.
- The default security group is locked down (no rules).
- Flow logs default to REJECT traffic only, with 14-day retention, to keep log cost low.
