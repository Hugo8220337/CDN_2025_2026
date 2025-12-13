resource "aws_lb" "api_alb" {
  name               = "ticket-master-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id] # security group do ALB
  
  # estou a usar as duas subnets públicas ciradas no network.tf
  # porque o ALB precisa de estar em subnets públicas para ser acessível da Internet
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
}

resource "aws_lb_target_group" "api_tg" {
  name        = "ticket-api-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path = "/health"
    matcher             = "200-299"  # Para aceitar qualquer código de sucesso
    interval            = 30         # Verifica a cada 30s
    timeout             = 5          # Espera 5s pela resposta
    healthy_threshold   = 2          # Precisa de 2 "Sim" para ficar verde
    unhealthy_threshold = 3          # Precisa de 3 falhas para ser removido
  }
}

# Listener do ALB para redirecionar o tráfego para o Target Group
# Serve para o Load Balancer estar permanentemente a ouvir na porta 80 para redirecionar o tráfego
# para o Target Group (a API)
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.api_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}

# Output para saberes o URL final
output "api_endpoint" {
  value = "http://${aws_lb.api_alb.dns_name}"
}