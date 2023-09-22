variable "create" {
  type = bool
  default = true
}

variable "service_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "leadgenius_cidrs" {
  type = list(string)
  default = [
    "10.0.0.0/16",
    "10.0.1.0/16",
    "10.0.2.0/16",
    "10.0.3.0/16",
    "10.0.4.0/16",
    "10.0.5.0/16"
  ]
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

variable "alb_sg_id" {
}

variable "image" {
  type = string
}

variable "environment_variables" {
  type = list(map(string))
  default = null
}
