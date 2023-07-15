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


variable "dimension_name" {
  type        = string
}

variable "dimension_value" {
  type        = string
}
