#--------------------------
# ECS Cluster for backend
#--------------------------

resource "aws_ecs_cluster" "backend_cluster" {
  name = "backend-ecs-cluster"
}

#--------------------------
# Service Discovery (Cloud Map) - O substituto do Load Balancer
#--------------------------
resource "aws_service_discovery_private_dns_namespace" "backend" {
  name        = "backend.local"
  description = "Service discovery for backend"
  vpc         = aws_vpc.main.id
}

#---------------------------------------------------
# Service Discovery for backend ECS Service
#----------------------------------------------------
resource "aws_service_discovery_service" "backend" {
  name = "service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.backend.id

    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

    
}

#--------------------------
# CloudWatch Log Group
#--------------------------
resource "aws_cloudwatch_log_group" "backend_logs" {
  name              = "/ecs/backend-task"
  retention_in_days = 7 # Guarda logs por 7 dias (podes mudar se quiseres)
}



#--------------------------
# ECS Task Definition for backend
#--------------------------
resource "aws_ecs_task_definition" "backend" {
    family                   = "backend-task"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "256"
    memory                   = "512"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    
    container_definitions = jsonencode([
        {
        name      = "backend-container"
        image     = "hugobpc/cdn_2025_2026-backend:latest" 
        essential = true
        portMappings = [
            {
            containerPort = 3000
            hostPort      = 3000
            }
        ],
        environment = [
            { 
            name  = "MONGO_URI", 
            value = var.mongo_atlas_url 
          }
        ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/backend-task"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
        }
    ])
}

#--------------------------
# Security Group for ECS Service
#--------------------------
resource "aws_security_group" "ecs_sg" {
    name        = "ecs-security-group"
    description = "Allow inbound traffic to ECS tasks"
    vpc_id      = aws_vpc.main.id

    #recebe da vpc
    ingress {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }
}

#--------------------------
# ECS Service for backend
#--------------------------
resource "aws_ecs_service" "backend_service" { 
    name            = "backend-ecs-service"
    cluster         = aws_ecs_cluster.backend_cluster.id
    task_definition = aws_ecs_task_definition.backend.arn
    desired_count   = 2
    launch_type     = "FARGATE"

    network_configuration {
        subnets         = [aws_subnet.private1.id, aws_subnet.private2.id]
        security_groups = [aws_security_group.ecs_sg.id]
        assign_public_ip = false
    }

    service_registries {
      registry_arn = aws_service_discovery_service.backend.arn
    }

}

