# 1. O Cluster (o agrupamento lógico)
resource "aws_ecs_cluster" "api_cluster" {
  name = "ticket-master-cluster"
}

# 2. A Definição da Tarefa (A "receita" do container)
resource "aws_ecs_task_definition" "api_task" {
  family                   = "api-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] # Usar Fargate
  cpu                      = "256"       # 0.25 vCPU
  memory                   = "512"       # 512 MB

  container_definitions = jsonencode([
    {
      name      = "api-container"
      image     = "hugobpc/cdn_2025_2026-backend:latest" # Imagem do Docker Hub
      essential = true
      portMappings = [
        {
          containerPort = 3000 # A porta que a API vai usar
          hostPort      = 3000
        }
      ]
      environment = [
        # URL para poder ligar ao mongo (vou usar o MongoDB Atlas)
        { name = "MONGO_URI", value = var.mongo_atlas_url }
      ]
    }
  ])
}

# 3. O Serviço (O que mantém a tarefa a correr)
resource "aws_ecs_service" "api_service" {
  name            = "api-service"
  cluster         = aws_ecs_cluster.api_cluster.id
  task_definition = aws_ecs_task_definition.api_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  # Preciso disto porque deu um erro e descubri que o 
  # contentor demora mais a ligar do que o healthcheck do alb.tf
  health_check_grace_period_seconds = 60 # Não fazer health checks nos primeiros 60s
  
  network_configuration {
    subnets          = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id] # As duas subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id] # O nosso novo grupo de segurança
  }

  # Liga o serviço ao Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.api_tg.arn
    container_name   = "api-container"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.front_end]
}

# Permite que o ECS envie logs para o CloudWatch
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/ecs/ticket-master-api"
  retention_in_days = 7 # Guarda logs por 7 dias para não pagares muito
}