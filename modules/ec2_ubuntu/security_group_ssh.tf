data "http" "ip" {
  url = "https://api.ipify.org?format=text"
}

resource "aws_security_group" "allow-ssh-ec2instance" {
  vpc_id = var.vpc_id
  name = "allow-ssh-ec2instance"
  description = "security group that allows ssh"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${data.http.ip.response_body}/32"]
  }

  tags = {
    Name = "allow-ssh-ec2instance"
  }
}

# data "aws_security_group" "alb-sg-id" {

#   filter {
#     name   = "group-name"
#     values = ["allow-custom-alb"]
#   }
# }

resource "aws_security_group" "allow-custom-ec2instance" {
  vpc_id = var.vpc_id
  name = "allow-custom-ec2instance"
  description = "security group that allows custom protocols and all egress traffic to the EC2 instance"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port = 80
  #   to_port = 80
  #   protocol = "tcp"
  #   security_groups = [data.aws_security_group.alb-sg-id.id]
  # }

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
    Name = "allow-custom-ec2instance"
  }
}
