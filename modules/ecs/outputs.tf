output "ecs_service_sg_ids" {
  value = module.ecs_security_group.security_group_id
}
