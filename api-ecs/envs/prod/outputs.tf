
# Command to view the status of the Fargate service
output "status" {
  value = module.api-ecs.status
}

# Command to deploy a new task definition to the service using Docker Compose
output "deploy" {
  value = module.api-ecs.deploy
}

# Command to scale up cpu and memory
output "scale_up" {
  value = module.api-ecs.scale_up
}

# Command to scale out the number of tasks (container replicas)
output "scale_out" {
  value = module.api-ecs.scale_out
}

# The AWS keys for the CICD user to use in a build system
output "cicd_id" {
  value = module.api-ecs.cicd_id
}
output "cicd_secret" {
  value = module.api-ecs.cicd_secret
}

# The URL for the docker image repo in ECR
output "docker_registry" {
  value = module.api-ecs.docker_registry
}

output "ssm_add_secret" {
  value = module.api-ecs.ssm_add_secret
}

output "ssm_add_secret_ref" {
  value = module.api-ecs.ssm_add_secret_ref
}

output "ssm_key_id" {
  value = module.api-ecs.ssm_key_id
}
