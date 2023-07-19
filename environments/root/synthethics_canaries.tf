module "canary" {
  source = "../../modules/synthethics_canaries"

  relative_path = "environments/root"
  source_dir = "canaries_code/nextcloud"
  canary_name = "nextcloud"
  vpc_id = module.vpc_networking.vpc_id 
  private_subnets_ids  = module.vpc_networking.private_subnets_ids
  private_subnet_cidr = module.vpc_networking.private_subnets_cidr
  alb_security_group_id = module.alb.alb-sg.id
  artifact_s3_location = "s3://cwt-syn-results-881422822893-us-east-1/canary/us-east-1/nextcloud"
  handler              = "main.handler"
  runtime_version      = "syn-python-selenium-1.3"
  start_canary = true
  expression = "rate(5 minutes)"

  depends_on = [
    module.alb,
    module.nextcloud-ecs
  ]
}
