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
      image     = "255731431520.dkr.ecr.eu-north-1.amazonaws.com/cdn_2025_2026/tp:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000 # A porta que a API vai usar
          hostPort      = 3000
        }
      ]
      environment = [
         # TODO ainda uso o ATLAS, mudar caso se implemente diretamente no AWS
        { name = "MONGO_URI", value = var.mongo_atlas_url } # URL para poder ligar ao mongo
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
  desired_count   = 1 # Começa com 1 instância mas se o uso da CPU subir a cima de 70% o auto scaling aumenta

  # Isso impede que o Open Tofu tente mudar o número de instâncias
  lifecycle {
    ignore_changes = [desired_count] 
  }

  # Preciso disto porque deu um erro, e após 1 horadescubri que o 
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
    container_port   = 3000 # A porta que a API vai usar
  }

  depends_on = [aws_lb_listener.front_end]
}
# Grupo de Logs no CloudWatch para a API
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/ecs/ticket-master-api"
  retention_in_days = 7 # Guarda logs por 7 dias (menos dias = menos abrir a carteira)
}


# ---------------------------
# Politiquices de AutoScaling
# ---------------------------
# Definir o Alvo de Auto Scaling
# Basicamente diz-se à AWS para esclar o serviço api_gateway_service entre 1 e 5 instâncias
# dependendo da carga de CPU
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.api_cluster.name}/${aws_ecs_service.api_service.name}" # serviço a escalar
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Definição da política de escala (Baseada em CPU)
# Dizemos à AWS: "Olha, se a média de CPU passar os 70%, cria mais tarefas para baixar a carga. Ok?"
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id # serviço a escalar
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  # Configuração de politiquices da escala
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization" # Métrica baseada na média de CPU (era a mais simples)
    }

    target_value = 70.0 # Objetivo é não passar os 70% da CPU
    scale_in_cooldown  = 300 # Espera 300s antes de destruir tarefas (evita pisca-pisca)
    scale_out_cooldown = 60  # Espera 60s antes de criar novas para evitar criar muitas de uma vez (fica caro)
  }
}