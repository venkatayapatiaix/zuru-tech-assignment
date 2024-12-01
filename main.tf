provider "aws" {
  region = "us-east-1" # Specify your AWS region
}

# ECR Repository to store Docker images
resource "aws_ecr_repository" "go_app" {
  name = "my-public-repo" # Change to your desired repository name
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# Attach the Amazon ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "go_app_cluster" {
  name = "go-app-cluster"
}

# ECS Task Definition (Fargate)
resource "aws_ecs_task_definition" "go_app_task" {
  family                   = "go-app-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "go-app",
      "image": "${aws_ecr_repository.go_app.repository_url}:latest",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

# ECS Service
resource "aws_ecs_service" "go_app_service" {
  name            = "go-app-service"
  cluster         = aws_ecs_cluster.go_app_cluster.id
  task_definition = aws_ecs_task_definition.go_app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0a67f2f023a59861b", "subnet-0234d9bfd6d76c779"] # Replace with your subnet IDs
    security_groups  = ["sg-0ef903dc239669251"]                                 # Replace with your security group ID
    assign_public_ip = true
  }
}

