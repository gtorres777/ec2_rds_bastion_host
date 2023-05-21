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
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-ec2instance.id}","${aws_security_group.allow-custom-ec2instance.id}"]
  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  # Packages installed with user data
  user_data = file("${var.path_to_user_data_script}")

  # IAM roles attached to the ec2 instance
  iam_instance_profile = "${aws_iam_instance_profile.s3-role-instanceprofile.name}"
}
