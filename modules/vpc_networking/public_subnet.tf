resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets_cidr)
  availability_zone       = element(var.availability_zones, count.index)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main_vpc.id

  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

# resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
#   replication_subnet_group_description = "Example replication subnet group"
#   replication_subnet_group_id          = "example-dms-replication-subnet-group-tf"

#   subnet_ids = aws_subnet.public_subnets.*.id

#   tags = {
#     Name = "dms_subnet_group"
#   }

#   depends_on = [
#     aws_subnet.public_subnets
#   ]
# }

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_subnets_rta" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnets.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eips" {
  count      = 1
  vpc        = true
  depends_on = [aws_internet_gateway.main_igw]
}

# resource "aws_nat_gateway" "nat_gws" {
#   count         = 1
#   allocation_id = aws_eip.nat_eips.*.id[count.index]
#   subnet_id     = aws_subnet.public_subnets.*.id[count.index]

#   tags = {
#     Name        = "nat-${count.index}"
#   }

#   depends_on = [aws_internet_gateway.main_igw]
# }


# resource "aws_security_group" "dms_sg" {
#   name = "dms_sg"
#   vpc_id      = aws_vpc.main_vpc.id

#   # Only Postgres in
#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow all outbound traffic.
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
