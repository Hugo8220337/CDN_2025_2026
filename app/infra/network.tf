# A tua nuvem privada
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnet (uma fatia da rede) onde os containers vão viver
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
}

# Gateway para a internet (para a API falar com o mundo)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Regras de routing
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}