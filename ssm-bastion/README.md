# ssm-bastion

A tiny EC2 instance that lets developers reach a private database through **SSM Session Manager port forwarding**. No inbound ports, no SSH keys, no VPN.

## Built-in standards

- **No inbound rules** on its security group. Outbound is only HTTPS to the SSM service and the database port to the database security group.
- IMDSv2 required, encrypted root volume, no public IP by default (`associate_public_ip_address = false`).
- Reachable only through SSM, so who may connect is controlled by IAM (`ssm:StartSession` permission), and sessions are logged by SSM.

## Usage

```hcl
module "bastion" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//ssm-bastion?ref=ssm-bastion-v1.1.0"

  name      = "rsa-staging"
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.private_subnet_ids[0]

  # Public-subnet variant without NAT or endpoints: use
  # module.network.public_subnet_ids[0] and set
  # associate_public_ip_address = true (still no inbound ports).

  database_security_group_ids = [module.db.security_group_id]
}
```

Then add `module.bastion.security_group_id` to the database's `allowed_security_group_ids`.

## How a developer connects

```
aws ssm start-session --target <instance_id> \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters host=<database address>,portNumber=5432,localPortNumber=5432
```

Then connect a database client to `localhost:5432`. Staging developers use the `db-staging-dev` group; prod uses the read-only group (IAM database authentication) described in `docs/standards.md`.

## Notes

- The subnet needs a path to SSM, in one of two ways:
  - Private subnet (default): a NAT gateway, or VPC endpoints for `ssm`, `ssmmessages` and `ec2messages` (the `network` module can create them with `interface_endpoints`).
  - Cheapest when there is no NAT: put the instance in a public subnet and set `associate_public_ip_address = true`. The instance reaches SSM through the internet gateway. The security group still has no inbound rules, so nothing can connect to it from the internet; access is only through SSM. The public IPv4 address costs about $3.65 a month, much less than three interface endpoints.
- Session logging to CloudWatch or S3 is an account-level SSM setting, not part of this module.
- The AMI is Amazon Linux 2023 (ARM). `ignore_changes = [ami]` keeps a new image from replacing the instance.

## Inputs

| Name | Description | Default |
|---|---|---|
| `name`, `vpc_id`, `subnet_id` | Identity and placement | required |
| `associate_public_ip_address` | Public IPv4 so a public subnet reaches SSM without NAT or endpoints (no inbound ports either way) | `false` |
| `instance_type` | Size | `t4g.nano` |
| `database_port` | Port to forward | `5432` |
| `database_security_group_ids` | Databases it may reach | `[]` |

## Outputs

`instance_id`, `security_group_id`, `role_arn`.

## Cost

About $3 a month for a `t4g.nano` running all day, plus about $3.65 for the public IPv4 address when `associate_public_ip_address = true`. Stop it when nobody needs it to save more.
