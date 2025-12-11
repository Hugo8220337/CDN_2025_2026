#---------------------
# VPC 
#---------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main-vpc"
  }
}

#---------------------
# Internet Gateway
#---------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-internet-gateway"
  }
}

#---------------------
# Subnets (2 public, 2 private)
#---------------------
resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true #give public IPs to instances launched in this subnet
  availability_zone = "${var.aws_region}a" #defining availability zone is a good practice

  tags = {
    Name = "main-vpc-public1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "main-vpc-public2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"



  tags = {
    Name = "main-vpc-private1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "main-vpc-private2"
  }
}

#---------------------
# Elastic IO for NAT Gateway
#---------------------
resource "aws_eip" "nat" {
  domain = "vpc"
}

#---------------------
# NAT Gateway
#---------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "main-nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
  
}

#---------------------
# Route Tables (public and private) and Route Associations
#---------------------

resource "aws_route_table" "public"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private2_assoc" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
