variable "vpc_id" {
  type        = string
  description = "vpc id that will contain the ALB"
}

variable "environment" {
  type        = string
  description = "Application Load Balancer name"
  default     = "My ALB"
}

variable "internal" {
  type        = string
  description = "Access state of the ALB"
  default     = "false"
}

variable "subnets_ids" {
  description = "Subnets ids where the ALB instance is going to be deployed"
}
