#-----------------------------------
# Security Group para o VPC Link
#-----------------------------------
resource "aws_security_group" "vpc_link_sg" {
  name        = "vpc-link-sg"
  description = "Security Group for API Gateway VPC Link"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#-----------------------------------
# VPC Link (Versão HTTP API)
#-----------------------------------
resource "aws_apigatewayv2_vpc_link" "backend_vpc_link" {
  name               = "backend-vpc-link"
  security_group_ids = [aws_security_group.vpc_link_sg.id]
  subnet_ids         = [aws_subnet.private1.id, aws_subnet.private2.id]

  tags = {
    Name = "backend-vpc-link"
  }
}

#-----------------------------------
# API Gateway HTTP (v2)
#-----------------------------------
resource "aws_apigatewayv2_api" "backend_api" {
  name          = "TicketMasterHTTPAPI"
  protocol_type = "HTTP"
}

#-----------------------------------
# Integração com Cloud Map (Service Discovery)
#-----------------------------------
resource "aws_apigatewayv2_integration" "backend_integration" {
  api_id           = aws_apigatewayv2_api.backend_api.id
  integration_type = "HTTP_PROXY"
  connection_type  = "VPC_LINK"
  connection_id    = aws_apigatewayv2_vpc_link.backend_vpc_link.id
  
  # Método de integração: Usar o Service Discovery ARN
  # O API Gateway vai resolver este ARN para os IPs dos teus contentores
  integration_uri    = aws_service_discovery_service.backend.arn
  integration_method = "ANY"
}

#-----------------------------------
# Rota (Route) - Captura tudo ($default)
#-----------------------------------
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.backend_api.id
  route_key = "$default" 
  target    = "integrations/${aws_apigatewayv2_integration.backend_integration.id}"
}

#-----------------------------------
# Stage (Deploy automático)
#-----------------------------------
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.backend_api.id
  name        = "$default" # Stage padrão
  auto_deploy = true
}

#-----------------------------------
# Output
#-----------------------------------
output "api_url" {
  description = "URL público da API"
  value       = aws_apigatewayv2_stage.prod.invoke_url
}