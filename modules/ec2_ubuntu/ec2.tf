data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "mykeypair" {
  key_name   = var.key_name
  public_key = file("${var.path_to_key}")
}

resource "aws_instance" "host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = "${var.ec2_name}"
  }

  # the VPC subnet
  subnet_id = var.subnet_id
  # the security group
  vpc_security_group_ids = ["${module.ec2-sg-server.security_group_id}",aws_security_group.allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  # Packages installed with user data
  user_data = file("${var.path_to_user_data_script}")

  # IAM roles attached to the ec2 instance
  iam_instance_profile = "${aws_iam_instance_profile.s3-role-instanceprofile.name}"
}

module "ec2-sg-server" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = "ec2-sg-server"
  description = "Default security group for ec2"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = [
    "101.0.0.0/16",
    "10.0.0.0/16",
  ]

  ingress_rules       = ["postgresql-tcp"]

  ingress_with_source_security_group_id = var.ingress_with_source_security_group_id

  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}
