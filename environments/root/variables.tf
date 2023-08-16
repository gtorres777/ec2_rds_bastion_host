variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets_cidr" {
  type = list(string)
}

variable "certificate_alb_private_arn" {
  type = string
  default = null
}
