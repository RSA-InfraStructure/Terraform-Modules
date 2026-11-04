# ssm-bastion

A tiny EC2 instance that lets developers reach a private database through **SSM Session Manager port forwarding**. No inbound ports, no SSH keys, no VPN.

## Built-in standards

- **No inbound rules** on its security group. Outbound is only HTTPS to the SSM service and the database port to the database security group.
- IMDSv2 required, encrypted root volume, no public IP.
- Reachable only through SSM, so who may connect is controlled by IAM (`ssm:StartSession` permission), and sessions are logged by SSM.

## Usage

```hcl
module "bastion" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//ssm-bastion?ref=ssm-bastion-v1.0.0"

  name      = "rsa-staging"
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.private_subnet_ids[0]

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

- The subnet needs a path to SSM: a NAT gateway, or VPC endpoints for `ssm`, `ssmmessages` and `ec2messages` (the `network` module can create them with `interface_endpoints`).
- Session logging to CloudWatch or S3 is an account-level SSM setting, not part of this module.
- The AMI is Amazon Linux 2023 (ARM). `ignore_changes = [ami]` keeps a new image from replacing the instance.

## Inputs

| Name | Description | Default |
|---|---|---|
| `name`, `vpc_id`, `subnet_id` | Identity and placement | required |
| `instance_type` | Size | `t4g.nano` |
| `database_port` | Port to forward | `5432` |
| `database_security_group_ids` | Databases it may reach | `[]` |

## Outputs

`instance_id`, `security_group_id`, `role_arn`.

## Cost

About $3 a month for a `t4g.nano` running all day. Stop it when nobody needs it to save more.
