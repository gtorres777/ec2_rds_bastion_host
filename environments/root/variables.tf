variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "private_subnets" {
  type    = string
}

variable "private_subnets_cidr" {
  type    = string
}
