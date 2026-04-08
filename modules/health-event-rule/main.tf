resource "aws_cloudwatch_event_rule" "this" {
  name          = var.name
  description   = var.description
  event_pattern = jsonencode(var.event_pattern)
  state         = var.enabled ? "ENABLED" : "DISABLED"

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for idx, target in var.targets : idx => target }

  rule      = aws_cloudwatch_event_rule.this.name
  target_id = lookup(each.value, "target_id", "target-${each.key}")
  arn       = each.value.arn

  dynamic "input_transformer" {
    for_each = lookup(each.value, "input_template", null) != null ? [1] : []
    content {
      input_paths    = lookup(each.value, "input_paths", {})
      input_template = each.value.input_template
    }
  }
}
