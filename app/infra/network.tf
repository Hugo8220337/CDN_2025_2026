resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = { Name = "ticket-master-vpc" }
}

# =======================================================
# 1. SUBNETS PÚBLICAS (Para o Load Balancer e NAT Gateway)
# =======================================================

# Subnet Pública 1 (Zona A) - Onde ficará o NAT Gateway
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true 

  tags = { Name = "Public-Subnet-1" }
}

# Subnet Pública 2 (Zona B) - NOVA: Necessária para o ALB funcionar em 2 zonas
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"      # Novo bloco de IP
  availability_zone       = "${var.aws_region}b" # Zona B
  map_public_ip_on_launch = true 

  tags = { Name = "Public-Subnet-2" }
}

# Porta para a Internet (Internet Gateway)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Tabela de rotas PÚBLICA (manda tráfego para o Gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associação da Subnet 1 à tabela pública
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Associação da Subnet 2 à tabela pública (NOVA)
resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# =======================================================
# 2. NAT GATEWAY (A "ponte" para a Internet)
# =======================================================
# IP Fixo para o NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# O NAT fica na subnet PÚBLICA 1 para ter acesso à rua
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  depends_on = [aws_internet_gateway.gw]
}

# =======================================================
# 3. SUBNET PRIVADA (Para o ECS Backend)
# =======================================================
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false # NÃO recebe IP público (Segurança!)

  tags = { Name = "Private-Subnet" }
}

# Tabela de rotas PRIVADA (manda tráfego para o NAT Gateway)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id # Usa o NAT, não o Gateway
  }
}

# Associação da subnet privada à tabela privada
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}