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

module "ec2_ubuntu" {
  source = "./modules/ec2_ubuntu"

  vpc_id        = module.vpc_networking.vpc_id
  path_to_key   = "keys/mykey.pub"
  ec2_name      = "ec2 bastion host"
  instance_type = "t3.micro"
  subnet_id     = module.vpc_networking.public_subnets_ids[1]

}

# module "rds-prod" {
#   source = "./modules/rds"

#   identifier = "rds-prod"
#   vpc_id               = module.vpc_networking.vpc_id
#   db_subnet_group_name = module.vpc_networking.aws_rds_subnet_group_id
#   db_name              = "rdsprod"
#   public_subnet_cidr = module.vpc_networking.public_subnets_cidr[1]
#   rds_sg_name = "rds_sg_1"
# }

# module "rds-staging" {
#   source = "./modules/rds"

#   identifier = "rds-staging"
#   vpc_id               = module.vpc_networking.vpc_id
#   db_subnet_group_name = module.vpc_networking.aws_rds_subnet_group_id
#   db_name              = "rdsstaging"
#   public_subnet_cidr = module.vpc_networking.public_subnets_cidr[0]
#   rds_sg_name = "rds_sg_2"
# }

# module "alarm" {
#   source = "./modules/alarms"

#   alarm_name                = "awsrds-premiere-prod-Low-Freeable-Memory"
#   comparison_operator       = "LessThanOrEqualToThreshold"
#   evaluation_periods        = 1
#   metric_name               = "FreeableMemory"
#   namespace                 = "AWS/RDS"
#   period                    = 300
#   statistic                 = "Average"
#   # threshold                 = 64424509440.0
#   threshold                 = 173020518


#   depends_on = [
#     module.rds-prod,
#     module.rds-staging
#   ]
# }

# module "endpoint-rds-staging" {
#   source = "./modules/endpoint"

#   database_name               = "rdsstaging"
#   server_name                 = module.rds-staging.rds_endpoint
#   endpoint_id                 = "src-rds-staging"
#   endpoint_type               = "source"
#   engine_name                 = "postgres"
#   username                    = module.rds-staging.master_username
#   password                    = "mysecret"
#   port                        = 5432
#   tag_name                    = "src-rds-staging"

#   depends_on = [
#     module.rds-prod,
#     module.rds-staging
#   ]
# }

# module "endpoint-rds-prod" {
#   source = "./modules/endpoint"

#   database_name               = "rdsprod"
#   server_name                 = module.rds-prod.rds_endpoint
#   endpoint_id                 = "tgt-rds-prod"
#   endpoint_type               = "target"
#   engine_name                 = "postgres"
#   username                    = module.rds-prod.master_username
#   password                    = "mysecret"
#   port                        = 5432
#   tag_name                    = "src-rds-prod"

#   depends_on = [
#     module.rds-prod,
#     module.rds-staging
#   ]
# }

# module "dms-instance" {
#   source = "./modules/dms_instance"

#   aws_dms_subnet_group_id = module.vpc_networking.aws_dms_subnet_group_id
#   dms_sg_id = module.vpc_networking.dms_sg_id

#   depends_on = [
#     module.rds-prod,
#     module.rds-staging,
#     module.endpoint-rds-prod,
#     module.endpoint-rds-staging
#   ]
# }

# module "dms-task" {
#   source = "./modules/dms_task"

#   replication_instance_arn = module.dms-instance.replication_instance_arn
#   source_endpoint_arn = module.endpoint-rds-staging.endpoint_arn
#   target_endpoint_arn = module.endpoint-rds-prod.endpoint_arn

#   depends_on = [
#     module.rds-prod,
#     module.rds-staging,
#     module.dms-instance
#   ]

# }

# module "lambda-dms-stop-tasks" {
#   source = "./modules/lambda"

#   relative_path = "/home/tux/Projects/AWS/practice/terraform_test"
#   source_dir = "lambdas_code/dms_stop_tasks/code"
#   output_path = "lambdas_code/dms_stop_tasks/code.zip"
#   lambda_function_name = "dms_stop_tasks"
#   # filename = "dms_stop_tasks/code/code.zip"
#   filename = "dms_stop_tasks/code.zip"
#   runtime = "python3.8"
#   handler = "main.lambda_handler"
#   policy_name = "dms_stop_tasks_policy"
#   policy_file_name = "dms-stop-tasks.json"

# }

# module "eventbridge-stop-dms-task" {
#   source = "./modules/eventbridge"

#   target_arn = module.lambda-dms-stop-tasks.lambda_arn
#   lambda_name = module.lambda-dms-stop-tasks.lambda_name
#   event_pattern = jsonencode({
#     "source": ["aws.cloudwatch"],
#     "detail-type": ["CloudWatch Alarm State Change"],
#     "resources": ["arn:aws:cloudwatch:us-east-1:111355452311:alarm:awsrds-premiere-prod-Low-Freeable-Memory"]
#     # "detail": {
#     #   "state": {
#     #     "value": [
#     #       "ALARM"
#     #     ]
#     #   }
#     # }
#   })

# }

module "alb" {
  source = "./modules/alb"

  vpc_id        = module.vpc_networking.vpc_id
  environment   = "Production"
  internal      = "false"
  subnets_ids     = module.vpc_networking.public_subnets_ids

}

module "nextcloud-ecs" {
    source = "./modules/ecs"
    create = true

    # Network/Account Settings
    vpc_id = module.vpc_networking.vpc_id
    private_subnets = module.vpc_networking.private_subnets_ids # Where be located the tasks.
    alb = module.alb # LoadBalancer

    target_group_arn = module.alb.nextcloud-tg-arn

    # Task Degfinition (Per Componente)
    task_web_port = 80 ## This must match with the por specified in 0.0.0.0:8000
    desired_tasks = 1
   
  depends_on = [
    module.alb
  ]
}

module "snstux" {
  source = "./modules/sns"
}

module "canary" {
  source = "./modules/cloudwatch_canary"

  relative_path = "/home/tux/Projects/AWS/practice/ec2_rds_bastion_host"
  source_dir = "canaries_code/nextcloud"
  output_path = "canaries_code/nextcloud"
  canaries_code_directory = "canaries_code/nextcloud"

  depends_on = [
    module.alb,
    module.nextcloud-ecs
  ]
}

module "alarm" {
  source = "./modules/alarms"

  alarm_name                = "Synthetics-Alarm-nextcloud"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Failed"
  namespace                 = "CloudWatchSynthetics"
  period                    = 900
  statistic                 = "Sum"
  threshold                 = 2.0
  dimensions_name            = "CanaryName"
  dimensions_value           = module.canary.cloudwatch_canary.name

  depends_on = [
    module.canary
  ]
}
