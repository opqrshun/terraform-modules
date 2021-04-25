
# Command to view the status of the Fargate service
output "status" {
  value = "fargate service info"
}

# Command to deploy a new task definition to the service using Docker Compose
output "deploy" {
  value = "fargate service deploy -f docker-compose.yml"
}

# Command to scale up cpu and memory
output "scale_up" {
  value = "fargate service update -h"
}

# Command to scale out the number of tasks (container replicas)
output "scale_out" {
  value = "fargate service scale -h"
}

# The AWS keys for the CICD user to use in a build system
output "cicd_id" {
  value = aws_iam_access_key.cicd_keys.id
}

output "cicd_secret" {
  value = aws_iam_access_key.cicd_keys.encrypted_secret
}

# The URL for the docker image repo in ECR
output "docker_registry" {
  value = data.aws_ecr_repository.ecr.repository_url
}
