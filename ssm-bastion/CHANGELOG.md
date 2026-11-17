# Changelog

## ssm-bastion-v1.1.0

- Added: `associate_public_ip_address` (bool, default `false`). Lets the bastion run in a public subnet and reach SSM through the internet gateway when there is no NAT or VPC endpoints. The security group still has no inbound rules.
- Backward compatible: the default keeps the previous behavior (no public IP), so v1.0.0 callers see no change in their plan.

## ssm-bastion-v1.0.0

- Initial release.
