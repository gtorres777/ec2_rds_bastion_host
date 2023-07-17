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
