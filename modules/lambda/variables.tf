variable "source_dir" {
  type        = string
}

variable "output_path" {
  type        = string
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the Lambda function"
}

variable "filename" {
  type        = string
}

variable "runtime" {
  type        = string
}

variable "handler" {
  type        = string
}

variable "policy_name" {
  type        = string
}

variable "policy_file_name" {
  type        = string
}
