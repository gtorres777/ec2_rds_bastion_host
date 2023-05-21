variable "vpc_id" {
  type        = string
  description = "vpc id that will contain the ALB"
}

variable "alb_name" {
  type        = string
  description = "Application Load Balancer name"
  default     = "My ALB"
}

variable "load_balancing_algorithm_type" {
  type        = string
  description = "algorithm type used for the ALB"
  default     = "round_robin"
}

variable "ec2_instance_id" {
  type        = string
  description = "ec2 instance id that will be targeted to the ALB"
}

variable "internal" {
  type        = string
  description = "Access state of the ALB"
  default     = "false"
}

variable "subnets_ids" {
  description = "Subnets ids where the ALB instance is going to be deployed"
}

variable "aws_acm_certificate_arn" {
  type        = string
  description = "ARN of the certificate generated from ACM"
}

