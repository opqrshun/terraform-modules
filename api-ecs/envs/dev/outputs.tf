
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

# The AWS keys for the CICD user to use in a build system
output "cicd_id" {
  value = module.dev.cicd_id
}
output "cicd_secret" {
  value = module.dev.cicd_secret
}

# The URL for the docker image repo in ECR
output "docker_registry" {
  value = module.dev.docker_registry
}

output "ssm_add_secret" {
  value = module.dev.ssm_add_secret
}

output "ssm_add_secret_ref" {
  value = module.dev.ssm_add_secret_ref
}

output "ssm_key_id" {
  value = module.dev.ssm_key_id
}
