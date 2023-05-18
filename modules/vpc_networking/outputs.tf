output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "public_subnets_cidr" {
  value = aws_subnet.public_subnets[*].cidr_block
}

output "aws_rds_subnet_group_id" {
  value = aws_db_subnet_group.rds_subnet_group.id
}
