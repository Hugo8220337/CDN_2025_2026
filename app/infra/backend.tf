# 1. O Cluster (o agrupamento lógico)
resource "aws_ecs_cluster" "api_cluster" {
  name = "ticket-master-cluster"
}

# 2. A Definição da Tarefa (A "receita" do container)
resource "aws_ecs_task_definition" "api_task" {
  family                   = "api-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] # Usar Fargate
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 512 MB

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
        { name = "MONGO_URL", value = "mongodb+srv://..." } 
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

  network_configuration {
    subnets          = [aws_subnet.main.id]
    assign_public_ip = true # Para poder aceder via internet
  }
}