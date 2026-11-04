locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"
  oidc_host       = "token.actions.githubusercontent.com"

  # The token subject that GitHub issues for the workflow run. It is what the
  # role trusts, so it must be exact (no wildcards).
  subjects = {
    for k, r in var.roles : k => (
      r.environment != null
      ? "repo:${r.github_repo}:environment:${r.environment}"
      : "repo:${r.github_repo}:ref:refs/heads/${r.branch}"
    )
  }

  managed_attachments = merge([
    for k, r in var.roles : {
      for arn in r.managed_policy_arns : "${k}|${arn}" => { role = k, arn = arn }
    }
  ]...)

  inline_roles = { for k, r in var.roles : k => r if r.policy_json != null }
}

################################################################################
# Identity provider (one per AWS account)
################################################################################

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = local.github_oidc_url
  client_id_list = ["sts.amazonaws.com"]

  tags = merge(var.tags, { Name = "github-actions" })
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1

  url = local.github_oidc_url
}

locals {
  provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

################################################################################
# Roles
################################################################################

data "aws_iam_policy_document" "trust" {
  for_each = var.roles

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = [local.subjects[each.key]]
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name                 = "${var.name_prefix}-${each.key}"
  description          = "GitHub Actions role for ${local.subjects[each.key]}"
  assume_role_policy   = data.aws_iam_policy_document.trust[each.key].json
  max_session_duration = each.value.max_session_duration

  tags = merge(var.tags, { Name = "${var.name_prefix}-${each.key}" })
}

resource "aws_iam_role_policy" "inline" {
  for_each = local.inline_roles

  name   = "deploy"
  role   = aws_iam_role.this[each.key].id
  policy = each.value.policy_json
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = local.managed_attachments

  role       = aws_iam_role.this[each.value.role].name
  policy_arn = each.value.arn
}
