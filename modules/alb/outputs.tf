output "nextcloud-tg-arn" {
  value = aws_lb_target_group.nextcloud.arn
}

output "alb-sg" {
  value = aws_security_group.default
}
