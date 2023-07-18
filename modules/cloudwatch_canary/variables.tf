variable "relative_path" {
  type        = string
}

variable "source_dir" {
  type        = string
}

variable "output_path" {
  type        = string
}

variable "canaries_code_directory" {
  type        = string
}

variable "vpc_id" {
  description = "vpc id"
}

variable "private_subnets_ids" {
  description = "private subnets ids"
}

variable "private_subnet_cidr" {
  description = "private subnets cidr"
}

variable "alb_security_group_id" {
  description = "ALB security group id"
}
