locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}

module "vpc_networking" {
  source = "./modules/vpc_networking"

  availability_zones = local.availability_zones
  aws_region         = var.aws_region

  vpc_cidr = "11.0.0.0/16"

  public_subnets_cidr      = ["11.0.1.0/24", "11.0.2.0/24"]
  private_subnets_rds_cidr = ["11.0.3.0/24", "11.0.4.0/24"]

}

# module "ec2_ubuntu" {
#   source = "./modules/ec2_ubuntu"

#   vpc_id        = module.vpc_networking.vpc_id
#   path_to_key   = "keys/mykey.pub"
#   ec2_name      = "ec2 bastion host"
#   instance_type = "t3.micro"
#   subnet_id     = module.vpc_networking.public_subnets_ids[1]

# }

module "rds-prod" {
  source = "./modules/rds"

  identifier = "rds-prod"
  vpc_id               = module.vpc_networking.vpc_id
  db_subnet_group_name = module.vpc_networking.aws_rds_subnet_group_id
  db_name              = "rdsprod"
  public_subnet_cidr = module.vpc_networking.public_subnets_cidr[1]
  rds_sg_name = "rds_sg_1"
}

module "rds-staging" {
  source = "./modules/rds"

  identifier = "rds-staging"
  vpc_id               = module.vpc_networking.vpc_id
  db_subnet_group_name = module.vpc_networking.aws_rds_subnet_group_id
  db_name              = "rdsstaging"
  public_subnet_cidr = module.vpc_networking.public_subnets_cidr[0]
  rds_sg_name = "rds_sg_2"
}

module "alarm" {
  source = "./modules/alarms"

  alarm_name                = "awsrds-premiere-prod-Low-Freeable-Memory"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "FreeableMemory"
  namespace                 = "AWS/RDS"
  period                    = 300
  statistic                 = "Average"
  # threshold                 = 64424509440.0
  threshold                 = 173020518


  depends_on = [
    module.rds-prod,
    module.rds-staging
  ]
}

module "endpoint-rds-staging" {
  source = "./modules/endpoint"

  database_name               = "rdsstaging"
  server_name                 = module.rds-staging.rds_endpoint
  endpoint_id                 = "src-rds-staging"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  username                    = module.rds-staging.master_username
  password                    = "mysecret"
  port                        = 5432
  tag_name                    = "src-rds-staging"

  depends_on = [
    module.rds-prod,
    module.rds-staging
  ]
}

module "endpoint-rds-prod" {
  source = "./modules/endpoint"

  database_name               = "rdsprod"
  server_name                 = module.rds-prod.rds_endpoint
  endpoint_id                 = "tgt-rds-prod"
  endpoint_type               = "target"
  engine_name                 = "postgres"
  username                    = module.rds-prod.master_username
  password                    = "mysecret"
  port                        = 5432
  tag_name                    = "src-rds-prod"

  depends_on = [
    module.rds-prod,
    module.rds-staging
  ]
}

module "dms-instance" {
  source = "./modules/dms_instance"

  aws_dms_subnet_group_id = module.vpc_networking.aws_dms_subnet_group_id
  dms_sg_id = module.vpc_networking.dms_sg_id

  depends_on = [
    module.rds-prod,
    module.rds-staging,
    module.endpoint-rds-prod,
    module.endpoint-rds-staging
  ]
}

module "dms-task" {
  source = "./modules/dms_task"

  replication_instance_arn = module.dms-instance.replication_instance_arn
  source_endpoint_arn = module.endpoint-rds-staging.endpoint_arn
  target_endpoint_arn = module.endpoint-rds-prod.endpoint_arn

  depends_on = [
    module.rds-prod,
    module.rds-staging,
    module.dms-instance
  ]

}

module "lambda-dms-stop-tasks" {
  source = "./modules/lambda"

  source_dir = "lambdas_code/dms_stop_tasks/code"
  output_path = "lambdas_code/dms_stop_tasks/code.zip"
  lambda_function_name = "dms_stop_tasks"
  filename = "dms_stop_tasks/code.zip"
  runtime = "python3.8"
  handler = "main.lambda_handler"
  policy_name = "dms_stop_tasks_policy"
  policy_file_name = "dms-stop-tasks.json"

}

module "eventbridge-stop-dms-task" {
  source = "./modules/eventbridge"

  target_arn = module.lambda-dms-stop-tasks.lambda_arn
  lambda_name = module.lambda-dms-stop-tasks.lambda_name

}
