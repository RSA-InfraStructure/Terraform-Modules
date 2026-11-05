data "aws_caller_identity" "current" {}

# The key policy delegates to IAM (account root). Who may use the key is then
# decided by IAM policies, so a role of one environment that has no policy for
# this key (for example staging on the prod key) cannot decrypt with it.
data "aws_iam_policy_document" "key" {
  statement {
    sid       = "EnableIamPolicies"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.key.json

  tags = merge(var.tags, { Name = var.name })

  # Losing a key makes everything encrypted with it unreadable.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.this.key_id
}
