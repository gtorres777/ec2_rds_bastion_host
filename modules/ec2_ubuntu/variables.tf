variable "vpc_id" {
  type        = string
  description = "vpc id that will contain the EC2 instance"
}

variable "key_name" {
  type        = string
  description = "Key pair name"
  default     = "mykey"
}

variable "path_to_key" {
  type        = string
  description = "Relative path from where to obtain the public keypair"
  default     = "keys/mykey.pub"
}

variable "path_to_user_data_script" {
  type        = string
  description = "Relative path from where to obtain the script to run as User data"
  default     = "userdata/psqlclient.sh"
}

variable "ec2_name" {
  type        = string
  description = "EC2 instance name"
  default     = "ec2 ubuntu host"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id where the EC2 instance is going to be deployed"
}

