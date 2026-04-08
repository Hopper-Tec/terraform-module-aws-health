variable "name" {
  description = "(Required) The name of the EventBridge rule."
  type        = string
}

variable "description" {
  description = "(Optional) The description of the EventBridge rule."
  type        = string
  default     = "AWS Health event alert rule"
}

variable "event_pattern" {
  description = "(Optional) The event pattern as a map. Defaults to AWS Health events."
  type = object({
    source      = list(string)
    detail-type = list(string)
    detail      = optional(map(list(string)))
  })
  default = {
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
  }
}

variable "enabled" {
  description = "(Optional) Whether the rule is enabled."
  type        = bool
  default     = true
}

variable "targets" {
  description = "(Required) List of targets for the rule. Each target must have an 'arn'. Optional: 'target_id', 'role_arn' (required for cross-account targets), 'input_template', 'input_paths'."
  type = list(object({
    arn            = string
    target_id      = optional(string)
    role_arn       = optional(string)
    input_template = optional(string)
    input_paths    = optional(map(string), {})
  }))
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags."
  type        = map(string)
  default     = {}
}
