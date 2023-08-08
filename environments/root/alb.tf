# module "alb" {
#   source = "../../modules/alb"

#   vpc_id        = module.vpc_networking.vpc_id
#   environment   = "Production"
#   internal      = "false"
#   subnets_ids     = module.vpc_networking.public_subnets_ids

# }
