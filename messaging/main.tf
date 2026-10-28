data "aws_caller_identity" "current" {}

locals {
  dlq_queues = { for k, q in var.queues : k => q if q.enable_dlq }
}

################################################################################
# Queues
################################################################################

resource "aws_sqs_queue" "dlq" {
  for_each = local.dlq_queues

  name                      = "${var.name}-${each.key}-dlq${each.value.fifo ? ".fifo" : ""}"
  fifo_queue                = each.value.fifo
  message_retention_seconds = each.value.dlq_retention_seconds
  sqs_managed_sse_enabled   = true

  tags = merge(var.tags, { Name = "${var.name}-${each.key}-dlq" })
}

resource "aws_sqs_queue" "this" {
  for_each = var.queues

  name                       = "${var.name}-${each.key}${each.value.fifo ? ".fifo" : ""}"
  fifo_queue                 = each.value.fifo
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  message_retention_seconds  = each.value.message_retention_seconds
  delay_seconds              = each.value.delay_seconds
  receive_wait_time_seconds  = each.value.receive_wait_time_seconds
  sqs_managed_sse_enabled    = true

  redrive_policy = each.value.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = each.value.max_receive_count
  }) : null

  tags = merge(var.tags, { Name = "${var.name}-${each.key}" })
}

################################################################################
# Topics
################################################################################

resource "aws_sns_topic" "this" {
  for_each = var.topics

  name                        = "${var.name}-${each.key}${each.value.fifo ? ".fifo" : ""}"
  fifo_topic                  = each.value.fifo
  content_based_deduplication = each.value.fifo ? true : null
  kms_master_key_id           = "alias/aws/sns"

  tags = merge(var.tags, { Name = "${var.name}-${each.key}" })
}

################################################################################
# Topic to queue subscriptions
################################################################################

locals {
  subscriptions = { for s in var.subscriptions : "${s.topic}-${s.queue}" => s }
}

resource "aws_sns_topic_subscription" "this" {
  for_each = local.subscriptions

  topic_arn            = aws_sns_topic.this[each.value.topic].arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.this[each.value.queue].arn
  raw_message_delivery = each.value.raw_delivery
  filter_policy        = each.value.filter_policy
}

# Allow the subscribed topics to send to their queues.
data "aws_iam_policy_document" "queue" {
  for_each = toset(distinct([for s in var.subscriptions : s.queue]))

  statement {
    sid       = "AllowSnsToSend"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this[each.value].arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [for s in var.subscriptions : aws_sns_topic.this[s.topic].arn if s.queue == each.value]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  for_each = data.aws_iam_policy_document.queue

  queue_url = aws_sqs_queue.this[each.key].id
  policy    = each.value.json
}
