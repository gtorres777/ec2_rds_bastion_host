## Certificate
data "aws_acm_certificate" "tux" {
  domain   = "*.gustavo-td.com"
  statuses = ["ISSUED"]
  most_recent = true
}


## END Certificate

resource "aws_lb" "default" {
  name               = var.environment
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default.id]
  subnets            = var.subnets_ids
}

## Listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.tux.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nextcloud.arn
  }
}
## END Listeners

##
## Listener Rules
##
resource "aws_lb_listener_rule" "nextcloud" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nextcloud.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
} 

##
## Target Groups
##
resource "aws_lb_target_group" "nextcloud" {
  name     = "nextcloud"
  port     = 80
  target_type = "ip"
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    matcher             = "200"
    path                = "/"
  }
}
##
## END Target Groups

## Default Security Group
resource "aws_security_group" "default" {
  name        = "alb-sg"
  description = "Application Load Balancer SG" 
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}
