variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "vpc_cidr" {
  type = string
}

# variable "public_subnets_cidr" {
#   type = list(string)
# }

variable "certificate_alb_private_arn" {
  type = any

  validation {
    condition     = can(tostring(var.certificate_alb_private_arn))
    error_message = "The \"certificate_alb_private_arn\" value must be a string."
  }
}
