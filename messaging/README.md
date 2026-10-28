# messaging

SQS queues (each with an optional dead-letter queue), SNS topics, and topic-to-queue subscriptions. All encrypted at rest.

## Example

```hcl
module "messaging" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//messaging?ref=v0.1.0"

  name = "rsa-prod"

  queues = {
    notifications = {}
    emails        = { visibility_timeout_seconds = 60 }
  }

  topics = {
    events = {}
  }

  subscriptions = [
    { topic = "events", queue = "notifications" },
  ]

  tags = { env = "prod" }
}
```

Grant your ECS task role access using the `queue_arns` and `topic_arns` outputs. Alarms on queue depth belong in the observability module.
