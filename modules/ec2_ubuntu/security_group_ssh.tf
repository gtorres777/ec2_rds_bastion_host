data "http" "ip" {
  url = "https://api.ipify.org?format=text"
}

resource "aws_security_group" "allow-ssh" {
  vpc_id = var.vpc_id
  name = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${data.http.ip.response_body}/32"]
  }

  tags = {
    Name = "allow-ssh"
  }
}
