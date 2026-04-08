module "health_event_rule" {
  source = "../../modules/health-event-rule"

  name        = "aws-health-alerts"
  description = "Captures AWS Health events and sends to SNS"

  targets = [
    {
      arn       = aws_sns_topic.this.arn
      target_id = "sns-health-alerts"
    }
  ]

  tags = {
    team       = "engineering"
    product    = "health-alerts"
    managed_by = "terraform"
  }
}

resource "aws_sns_topic" "this" {
  name = "aws-health-alerts"

  tags = {
    team       = "engineering"
    product    = "health-alerts"
    managed_by = "terraform"
  }
}
