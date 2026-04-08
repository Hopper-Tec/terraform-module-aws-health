resource "aws_cloudwatch_event_rule" "this" {
  name          = var.name
  description   = var.description
  event_pattern = jsonencode({ for k, v in var.event_pattern : k => v if v != null })
  state         = var.enabled ? "ENABLED" : "DISABLED"

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for idx, target in var.targets : idx => target }

  rule      = aws_cloudwatch_event_rule.this.name
  target_id = coalesce(each.value.target_id, format("target-%s", each.key))
  arn       = each.value.arn
  role_arn  = each.value.role_arn

  dynamic "input_transformer" {
    for_each = each.value.input_template != null ? [1] : []
    content {
      input_paths    = each.value.input_paths
      input_template = each.value.input_template
    }
  }
}
