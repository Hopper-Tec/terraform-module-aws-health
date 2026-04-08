# health-event-rule

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.39.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the EventBridge rule. | `string` | `"AWS Health event alert rule"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | (Optional) Whether the rule is enabled. | `bool` | `true` | no |
| <a name="input_event_pattern"></a> [event\_pattern](#input\_event\_pattern) | (Optional) The event pattern as a map. Defaults to AWS Health events. | <pre>object({<br/>    source      = list(string)<br/>    detail-type = list(string)<br/>    detail      = optional(map(list(string)))<br/>  })</pre> | <pre>{<br/>  "detail-type": [<br/>    "AWS Health Event"<br/>  ],<br/>  "source": [<br/>    "aws.health"<br/>  ]<br/>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the EventBridge rule. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(string)` | `{}` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | (Required) List of targets for the rule. Each target must have an 'arn'. Optional: 'target\_id', 'input\_template', 'input\_paths'. | <pre>list(object({<br/>    arn            = string<br/>    target_id      = optional(string)<br/>    input_template = optional(string)<br/>    input_paths    = optional(map(string), {})<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_event_rule_arn"></a> [cloudwatch\_event\_rule\_arn](#output\_cloudwatch\_event\_rule\_arn) | The ARN of the EventBridge rule. |
| <a name="output_cloudwatch_event_rule_id"></a> [cloudwatch\_event\_rule\_id](#output\_cloudwatch\_event\_rule\_id) | The ID of the EventBridge rule. |
| <a name="output_cloudwatch_event_rule_name"></a> [cloudwatch\_event\_rule\_name](#output\_cloudwatch\_event\_rule\_name) | The name of the EventBridge rule. |
<!-- END_TF_DOCS -->
