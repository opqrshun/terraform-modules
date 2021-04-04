
# Command to view the status of the Fargate service
output "status" {
  value = module.dev.status
}

# Command to deploy a new task definition to the service using Docker Compose
output "deploy" {
  value = module.dev.deploy
}

# Command to scale up cpu and memory
output "scale_up" {
  value = module.dev.scale_up
}

# Command to scale out the number of tasks (container replicas)
output "scale_out" {
  value = module.dev.scale_out
}
