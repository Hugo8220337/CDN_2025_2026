# -------------------------
# Segurança no ALB (Aceita tráfego HTTP de qualquer lugar)
# -------------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.main.id # VPC onde o ALB está

  # Permitir tráfego HTTP de qualquer lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Todos podem aceder ao Load Balancer
  }

  # Permitir todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# Segurança no ECS (Aceita apenas o tráfego do Load Balancer)
# -------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.main.id # VPC onde o ECS está

  # Permitir tráfego apenas do ALB na porta 3000
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # é no security group do ALB que se permite o acesso apenas do ALB
  }

  # Permitir todo o tráfego de saída (preciso disto para poder falar com o MongoDB)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # O container precisa de sair para falar com o Mongo
  }
}