output "ecr_repository_url" {
  value       = aws_ecr_repository.go_app.repository_url
  description = "The URL of the ECR repository"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.go_app_cluster.name
  description = "The name of the ECS cluster"
}
