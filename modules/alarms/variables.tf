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
}

variable "namespace" {
  type        = string
}

variable "period" {
  type        = number
}

variable "statistic" {
  type        = string
}

variable "threshold" {
  type        = number
}


variable "dimensions_name" {
  type        = string
}

variable "dimensions_value" {
  type        = string
}

variable "alarm_actions" {
  type        = list(string)
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}
