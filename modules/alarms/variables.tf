variable "alarm_name" {
  type        = string
}

variable "comparison_operator" {
  type        = string
}

variable "evaluation_periods" {
  type        = number
}

variable "metric_name" {
  type        = string
  default = null
}

variable "namespace" {
  type        = string
  default = null
}

variable "period" {
  type        = number
  default = null
}

variable "statistic" {
  type        = string
  default = null
}

variable "threshold" {
  type        = number
  default = null
}

variable "dimensions_name" {
  type        = string
  default = null
}

variable "dimensions_value" {
  type        = string
  default = null
}

variable "alarm_actions" {
  type        = list(string)
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "ok_actions" {
  type        = list(string)
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "use_metric_query" {
  description = "Flag to determine whether to use metric queries for the alarm"
  type        = bool
  default     = false
}

variable "threshold_metric_id" {
  type        = string
  default     = null
  description = "The ID of the metric query."
}

variable "metric_queries" {
  description = "List of metric queries for query-based alarms"
  default     = null
  type        = list(object({
    id         = string
    expression = optional(string)
    label      = optional(string)
    return_data = bool
    metric    = optional(list(object({
      metric_name = string
      namespace   = string
      period      = number
      stat        = string
      unit        = string
      dimensions  = map(string)
    })))
  }))
}
