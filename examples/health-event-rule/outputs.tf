output "cloudwatch_event_rule_arn" {
  description = "The ARN of the EventBridge rule."
  value       = module.health_event_rule.cloudwatch_event_rule_arn
}

output "cloudwatch_event_rule_name" {
  description = "The name of the EventBridge rule."
  value       = module.health_event_rule.cloudwatch_event_rule_name
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.this.arn
}
