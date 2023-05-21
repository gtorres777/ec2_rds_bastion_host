resource "aws_lb_target_group" "tg_alb" {
  name       = "My-tg-for-ALB"
  port       = 8080
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  slow_start = 0

  load_balancing_algorithm_type = var.load_balancing_algorithm_type

  # health_check {
  #   enabled             = true
  #   port                = 8081
  #   interval            = 30
  #   protocol            = "HTTP"
  #   path                = "/health"
  #   matcher             = "200"
  #   healthy_threshold   = 3
  #   unhealthy_threshold = 3
  # }
}

resource "aws_lb_target_group_attachment" "tg_atch_elb" {

  target_group_arn = aws_lb_target_group.tg_alb.arn
  target_id        = var.ec2_instance_id
  port             = 80
}


resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  # security_groups    = [aws_security_group.alb_eg1.id]

  # access_logs {
  #   bucket  = "my-logs"
  #   prefix  = "my-app-lb"
  #   enabled = true
  # }

  subnets = var.subnets_ids
}

resource "aws_alb_listener" "frontend-listeners" {
  load_balancer_arn = aws_lb.alb.arn
  port = "80"

  default_action {
    target_group_arn = "${aws_lb_target_group.tg_alb.arn}"
    type = "forward"
  }

}
