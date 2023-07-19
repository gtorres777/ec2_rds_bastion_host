locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}

module "vpc_networking" {
  source = "../../modules/vpc_networking"

  availability_zones = local.availability_zones
  aws_region         = var.aws_region

  vpc_cidr = "11.0.0.0/16"

  public_subnets_cidr      = ["11.0.1.0/24", "11.0.2.0/24"]
  private_subnets_rds_cidr = ["11.0.3.0/24", "11.0.4.0/24"]

}
