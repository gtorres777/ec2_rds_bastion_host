variable "relative_path" {
  type        = string
}

variable "source_dir" {
  type        = string
}

variable "canary_name" {
  description = "Name for the synthethic canary"
}

variable "vpc_id" {
  description = "vpc id"
  default = null
}

variable "private_subnets_ids" {
  description = "private subnets ids"
  default = null
}

variable "private_subnet_cidr" {
  description = "private subnets cidr"
  default = null
}

variable "alb_security_group_id" {
  description = "ALB security group id"
}

variable "artifact_s3_location" {
  description = "S3 URL where the artifacts from the canary will be stored"
}

variable "handler" {
  description = "Name of the filename of the canary code concatenated with the entrypoint main function in the lambda code, for example main.lambda_handler"
}

variable "runtime_version" {
  description = "Runtime to run the canary code, for example syn-python-selenium-1.x, syn-nodejs-puppeteer-3.x, etc"
}

variable "start_canary" {
  description = "Boolean variable to start the synthethic canary or not when created"
}

variable "expression" {
  description = "Rate of time on how frequently run the canary code"
}
