module "alb" {
  source = "../../modules/alb"

  vpc_id        = module.vpc_networking.vpc_id
  environment   = "Production"
  internal      = "false"
  subnets_ids     = module.vpc_networking.public_subnets_ids
  certificate_arn   = var.certificate_alb_private_arn   
}
