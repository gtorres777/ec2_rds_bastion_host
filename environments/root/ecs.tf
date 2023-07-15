module "service_nextcloud" {
    source = "../../modules/ecs"
    create = true

    # Network/Account Settings
    vpc_id = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnets # Where be located the tasks.
    alb = module.alb # LoadBalancer
    target_group_arn = module.alb.webflow_tg.arn

    # Task Degfinition (Per Componente)
    task_web_port = 8101 ## This must match with the por specified in 0.0.0.0:8000
    desired_tasks = 0

    # Don't forget to match task_web_port with the 0.0.0.0:8000 (Per Component)
    entry_point = []
}
