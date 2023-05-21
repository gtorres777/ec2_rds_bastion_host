locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}

module "vpc_networking" {
  source = "./modules/vpc_networking"

  availability_zones = local.availability_zones
  aws_region         = var.aws_region

  vpc_cidr = "11.0.0.0/16"

  public_subnets_cidr      = ["11.0.1.0/24", "11.0.2.0/24"]
  # private_subnets_rds_cidr = ["11.0.3.0/24", "11.0.4.0/24"]

}

# module "sg"{

# }

module "ec2_ubuntu" {
  source = "./modules/ec2_ubuntu"

  vpc_id        = module.vpc_networking.vpc_id
  path_to_key   = "keys/mykey.pub"
  ec2_name      = "ec2 bastion host"
  instance_type = "t3.micro"
  subnet_id     = module.vpc_networking.public_subnets_ids[0]

}

# module "rds" {
#   source = "./modules/rds"

#   vpc_id               = module.vpc_networking.vpc_id
#   db_subnet_group_name = module.vpc_networking.aws_rds_subnet_group_id
#   public_subnet_cidr = module.vpc_networking.public_subnets_cidr[1]
# }

module "acm" {
  source = "./modules/acm"

}

module "alb" {
  source = "./modules/alb"

  vpc_id        = module.vpc_networking.vpc_id
  ec2_instance_id = module.ec2_ubuntu.ec2_instance_id
  alb_name      = "My-ALB"
  internal      = "false"
  subnets_ids     = module.vpc_networking.public_subnets_ids
  aws_acm_certificate_arn  = module.acm.aws_acm_certificate_arn

}
