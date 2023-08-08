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

# module "rds-dataddo-sg" {
#   source      = "terraform-aws-modules/security-group/aws"
#   version     = "4.17.1"
#   name        = "rds-dataddo-sg"
#   description = "Allow dataddo IPs service"
#   vpc_id      = module.vpc_networking.vpc_id

#   ingress_cidr_blocks = [
#     "52.210.57.95/32",
#     "52.17.68.150/32",
#     "52.214.115.147/32",
#     "54.77.45.35/32",
#     "52.30.37.137/32",
#     "18.200.46.19/32"
#   ]

#   ingress_rules       = ["postgresql-tcp"]

#   egress_cidr_blocks  = ["0.0.0.0/0"]
#   egress_rules        = ["all-all"]
# }

# module "rds-retool-sg" {
#   source      = "terraform-aws-modules/security-group/aws"
#   version     = "4.17.1"
#   name        = "rds-retool-sg"
#   description = "Allow Retool IPs service"
#   vpc_id      = module.vpc_networking.vpc_id

#   ingress_cidr_blocks = [
#     "44.208.168.68/30",
#     "35.90.103.132/30"
#   ]

#   ingress_rules       = ["postgresql-tcp"]

#   egress_cidr_blocks  = ["0.0.0.0/0"]
#   egress_rules        = ["all-all"]
# }

# module "rds-dbt-sg" {
#   source      = "terraform-aws-modules/security-group/aws"
#   version     = "4.17.1"
#   name        = "rds-dbt-sg"
#   description = "Allow DBT IPs service"
#   vpc_id      = module.vpc_networking.vpc_id

#   ingress_cidr_blocks = [
#     "3.126.140.248/32",
#     "52.45.144.63/32",
#     "3.72.153.148/32",
#     "3.123.45.39/32",
#     "54.81.134.249/32",
#     "52.22.161.231/32"
#   ]

#   ingress_rules       = ["postgresql-tcp"]

#   egress_cidr_blocks  = ["0.0.0.0/0"]
#   egress_rules        = ["all-all"]
# }

# module "rds-vpc-sg" {
#   source      = "terraform-aws-modules/security-group/aws"
#   version     = "4.17.1"
#   name        = "rds-vpc-sg"
#   description = "Allow from internal VPC"
#   vpc_id      = module.vpc_networking.vpc_id

#   ingress_cidr_blocks = [
#     "172.17.160.0/20"
#   ]

#   ingress_rules       = ["postgresql-tcp"]

#   egress_cidr_blocks  = ["0.0.0.0/0"]
#   egress_rules        = ["all-all"]
# }

# module "ec2_ubuntu" {
#   source = "./modules/ec2_ubuntu"

#   vpc_id        = module.vpc_networking.vpc_id
#   path_to_key   = "keys/mykey.pub"
#   ec2_name      = "ec2 bastion host"
#   instance_type = "t3.micro"
#   subnet_id     = module.vpc_networking.public_subnets_ids[1]

#   ingress_with_source_security_group_id = [
#     {
#       description              = "datadoo"
#       rule                     = "postgresql-tcp"
#       source_security_group_id = module.rds-dataddo-sg.security_group_id
#     },
#     {
#       description              = "retool"
#       rule                     = "postgresql-tcp"
#       source_security_group_id = module.rds-retool-sg.security_group_id
#     },
#     {
#       description              = "Access for DBT"
#       rule                     = "postgresql-tcp"
#       source_security_group_id = module.rds-dbt-sg.security_group_id
#     },
#     {
#       description              = "Allow from internal VPC"
#       rule                     = "postgresql-tcp"
#       source_security_group_id = module.rds-vpc-sg.security_group_id
#     }
#   ]

# }

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

# module "alb" {
#   source = "./modules/alb"

#   vpc_id        = module.vpc_networking.vpc_id
#   environment   = "Production"
#   internal      = "false"
#   subnets_ids     = module.vpc_networking.public_subnets_ids

# }

# module "nextcloud-ecs" {
#     source = "./modules/ecs"
#     create = true

#     # Network/Account Settings
#     vpc_id = module.vpc_networking.vpc_id
#     private_subnets = module.vpc_networking.private_subnets_ids # Where be located the tasks.
#     alb = module.alb # LoadBalancer

#     target_group_arn = module.alb.nextcloud-tg-arn

#     # Task Degfinition (Per Componente)
#     task_web_port = 80 ## This must match with the por specified in 0.0.0.0:8000
#     desired_tasks = 1
#     alb_sg_id = module.alb.alb-sg.id
#    
#   depends_on = [
#     module.alb
#   ]
# }

module "snstux" {
  source = "./modules/sns"
}

# module "canary" {
#   source = "./modules/synthethics_canaries"

#   relative_path = "/home/tux/Projects/AWS/practice/ec2_rds_bastion_host"
#   source_dir = "canaries_code/nextcloud"
#   canary_name = "nextcloud"
#   vpc_id = module.vpc_networking.vpc_id 
#   private_subnets_ids  = module.vpc_networking.private_subnets_ids
#   private_subnet_cidr = module.vpc_networking.private_subnets_cidr
#   alb_security_group_id = module.alb.alb-sg.id
#   artifact_s3_location = "s3://cwt-syn-results-881422822893-us-east-1/canary/us-east-1/nextcloud"
#   handler              = "main.handler"
#   runtime_version      = "syn-python-selenium-1.3"
#   start_canary = true
#   expression = "rate(5 minutes)"

#   depends_on = [
#     module.alb,
#     module.nextcloud-ecs
#   ]
# }

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
  # dimensions_value           = module.canary.cloudwatch_canary.name
  dimensions_value           = "nextcloud"
  alarm_actions = [module.snstux.aws_sns_topic_arn]
  ok_actions          = [module.snstux.aws_sns_topic_arn]

  # depends_on = [
  #   module.canary
  # ]
}

# module "wazuh-server" {
#   source      = "terraform-aws-modules/security-group/aws"
#   version     = "4.16.1"
#   name        = "logging-wazu-server"
#   description = "Default security group for Wazuh"
#   vpc_id      = module.vpc_networking.vpc_id

#   ingress_cidr_blocks = [
#     "52.30.0.0/16",
#     "52.16.0.0/21",
#   ]
#   ingress_rules       = ["postgresql-tcp"]
#   egress_cidr_blocks  = ["0.0.0.0/0"]
#   egress_rules        = ["all-all"]
# }

# data "aws_security_group" "selected" {
#   id = "sg-03e2897d0a45e8b75"
# }

# module "wazuh2-server" {
#   source      = "terraform-aws-modules/security-group/aws"
#   version     = "4.16.1"
#   name        = "logging-wazu2-server"
#   description = "Default security group for Wazuh"
#   vpc_id      = module.vpc_networking.vpc_id

#   ingress_cidr_blocks = [
#     "101.0.0.0/16",
#     "10.0.0.0/16",
#   ]

#   ingress_with_source_security_group_id = [
#     {
#       description              = "datadoo"
#       rule                     = "http-80-tcp"
#       source_security_group_id = data.aws_security_group.selected.id
#     },
#   ]
#   ingress_rules       = ["postgresql-tcp"]
#   egress_cidr_blocks  = ["0.0.0.0/0"]
#   egress_rules        = ["all-all"]
# }
