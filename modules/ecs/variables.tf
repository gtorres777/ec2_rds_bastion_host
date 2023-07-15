variable "create" {
  type = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "task_web_port" {
  type = number
}

variable "desired_tasks" {
  type = number
}

variable "private_subnets" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "alb" {
}

variable "is_a_worker" {
    type = bool
    default = false
}
