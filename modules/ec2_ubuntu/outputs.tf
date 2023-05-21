output "ec2_instance_ip" {
  value = aws_instance.host.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.host.id
}
