# Cluster ECS para a API
resource "aws_ecs_cluster" "api_cluster" {
  name = "ticket-master-cluster"
}

# Definição da Tarefa (Task Definition) para a API
resource "aws_ecs_task_definition" "api_task" {
  family                   = "api-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] # Usar Fargate (para ser serverless)
  cpu                      = "256"       # 0.25 vCPU
  memory                   = "512"       # 512 MB

  # para os logs funcionarem aparentemente é preciso esta role
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

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
        # URL para poder ligar ao mongo (uso o MongoDB Atlas)
        { name = "MONGO_URI", value = var.mongo_atlas_url }
      ]

      # Configuração dos logs para o CloudWatch
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# Serviço ECS para correr a API no cluster definido
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
    subnets          = [aws_subnet.private_subnet.id] # está na subnet privada
    assign_public_ip = false # ECS Fargate em subnet privada não pode ter IP público
    security_groups  = [aws_security_group.ecs_sg.id] # TODO acho que não defini este security group
  }

  # Liga o serviço ao Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.api_tg.arn
    container_name   = "api-container"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.front_end]
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/ecs/ticket-master-api"
  retention_in_days = 7 # Guarda logs por 7 dias (poupa dinheiro)
}