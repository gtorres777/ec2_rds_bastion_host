output "rds_endpoint" {
  value = aws_db_instance.rds_instance.address
}

output "db_cluster_identifier" {
  value = aws_db_instance.rds_instance.id
}

output "master_username" {
  value = aws_db_instance.rds_instance.username
}

output "rds" {
  value = aws_db_instance.rds_instance
}
