# Only the secret container is created. No aws_secretsmanager_secret_version is
# declared on purpose: the value is set by a person (console or CLI) after the
# container exists, so it never appears in code, tfvars, CI variables or state.
resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = "${var.name_prefix}/${each.key}"
  description             = each.value.description
  kms_key_id              = each.value.kms_key_id
  recovery_window_in_days = each.value.recovery_window_in_days

  tags = merge(var.tags, { Name = "${var.name_prefix}/${each.key}" })
}
