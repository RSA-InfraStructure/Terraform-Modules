# service-budget

One monthly AWS Budget filtered to a single AWS **service** (for example Amazon SES), sending alerts to an existing SNS topic. Use it as a cheap guard against abuse or a runaway loop. It does not stop anything; it only alerts.

## Alerts

- **Actual spend** at each of `actual_thresholds` (default 80% and 100% of the limit).
- **Forecast** over each of `forecast_thresholds` (default 100%).

## Before you use it

The SNS topic must let AWS Budgets publish. With the `alarms` module (v1.2.0 or later) set `allow_budgets_publish = true`. That adds the topic policy statement and the KMS key statement for `budgets.amazonaws.com`. Without it the budget is created but alerts are never delivered.

## Usage

```hcl
module "ses_budget" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//service-budget?ref=service-budget-v1.0.0"

  name           = "rsa-dev"
  budget_suffix  = "ses"
  service        = "Amazon Simple Email Service"
  limit_usd      = 5
  sns_topic_arns = [module.alarms.topic_arn]
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `name` | Budget name prefix | required |
| `budget_suffix` | Name suffix (budget is `<name>-<suffix>-monthly`) | required |
| `service` | Cost Explorer service name | required |
| `limit_usd` | Monthly limit | required |
| `sns_topic_arns` | Alert topics | required |
| `actual_thresholds` | Percent of limit, actual | `[80, 100]` |
| `forecast_thresholds` | Percent of limit, forecast | `[100]` |

## Outputs

`budget_name`.

## Cost

The first two budgets in an account are free. After that each budget costs about $0.10 a day.
