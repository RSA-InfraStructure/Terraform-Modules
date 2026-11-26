# Changelog

## network-v1.1.0

- Added: `nat_eip_allocation_ids` (list(string), default `[]`). Reuse Elastic IPs created outside the module so the NAT public IP survives a NAT or module rebuild. The list must be empty or have one ID per NAT gateway (checked by a precondition on the NAT gateway).
- Changed: `aws_eip.nat` is created only when the list is empty; the output `nat_public_ips` returns the module-owned or external IPs (external IPs are read with `data "aws_eip"`, which needs `ec2:DescribeAddresses`).
- Backward compatible: with the default `[]` the resource addresses and values are unchanged, so v1.0.0 callers see no change in their plan.

## network-v1.0.0

- Initial release.
