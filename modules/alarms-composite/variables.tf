variable "alarm_name" {
  type        = string
  description = "Name of the alarm"
}

variable "alarm_actions" {
  type        = list(string)
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "ok_actions" {
  type        = list(string)
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "composite_alarm_rule" {
  type        = string
  description = "An expression that specifies which other alarms are to be evaluated to determine this composite alarm's state."
}
