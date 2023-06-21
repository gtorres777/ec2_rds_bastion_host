resource "aws_dms_endpoint" "test" {
  database_name               = var.database_name
  server_name                 = var.server_name
  endpoint_id                 = var.endpoint_id
  endpoint_type               = var.endpoint_type
  engine_name                 = var.engine_name
  username = var.username
  password                    = var.password
  port                        = var.port

  tags = {
    Name = var.tag_name
  }

}
