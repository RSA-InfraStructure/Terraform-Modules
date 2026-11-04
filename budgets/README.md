# budgets

One monthly AWS Budget for an application, filtered by a cost allocation tag, with email alerts. It implements the budget rule: target $200, hard cap $250.

## Alerts

- **Actual spend** at 50%, 80% and 100% of `target_usd`.
- **Forecast** over `cap_usd` (the $250 hard cap), so you hear about a red month before it ends.

## Before you use it

The tag has to be **activated as a cost allocation tag** in the AWS Billing console (Billing → Cost allocation tags → activate `app` and `env`). It can take up to 24 hours to take effect, and tags only count for spend after activation. A person with billing access does this once.

## Usage

```hcl
module "budget" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//budgets?ref=budgets-v1.0.0"

  name      = "rsa-api"
  tag_key   = "app"
  tag_value = "api"
  emails    = ["abdul.rehman@renegadesolutions.asia"]
}
```

Use `tag_key = "env"` for one budget per environment when staging and prod share an account.

## Inputs

| Name | Description | Default |
|---|---|---|
| `name` | Budget name prefix | required |
| `tag_value` | Value of the cost tag | required |
| `emails` | Alert recipients | required |
| `tag_key` | `app` or `env` | `app` |
| `target_usd` | Monthly budget | `200` |
| `cap_usd` | Hard cap for the forecast alert | `250` |

## Outputs

`budget_name`.

## Cost

The first two budgets in an account are free. After that each budget costs about $0.10 a day.
