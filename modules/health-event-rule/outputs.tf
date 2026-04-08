output "cloudwatch_event_rule_arn" {
  description = "The ARN of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.this.arn
}

output "cloudwatch_event_rule_id" {
  description = "The ID of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.this.id
}

output "cloudwatch_event_rule_name" {
  description = "The name of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.this.name
}
