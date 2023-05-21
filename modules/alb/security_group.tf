resource "aws_security_group" "allow-custom-alb" {
  vpc_id = var.vpc_id
  name = "allow-custom-alb"
  description = "security group that allows custom protocols and all egress traffic to ALB"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-custom-alb"
  }
}
