# output "ec2_bastionhost_ip" {
#   value = module.ec2_ubuntu.ec2_instance_ip
# }

output "rds_endpoint_access" {
  value = module.rds-prod.rds_endpoint
}

