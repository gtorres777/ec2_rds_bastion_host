resource "aws_dms_replication_task" "test" {
  migration_type            = "full-load"
  replication_instance_arn  = var.replication_instance_arn
  replication_task_id       = "test-dms-replication-task-tf"
  source_endpoint_arn       = var.source_endpoint_arn
  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
  target_endpoint_arn = var.target_endpoint_arn

  tags = {
    Name = "testtask"
  }

}
