# module "nextcloud-ecs" {
#     source = "../../modules/ecs"
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
#     depends_on = [
#       module.alb
#     ]
# }
