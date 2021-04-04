
# Command to view the status of the Fargate service
output "vpc_id" {
  value = module.env.vpc_id
}

output "private_subnets" {
  value = module.env.private_subnets
}

output "public_subnets" {
  value = module.env.public_subnets
}

output "vpc_cidr_block" {
  value = module.env.vpc_cidr_block
}

output "igw_id" {
  value = module.env.igw_id
}

# ACM
output "certificate_arn" {
  value = module.env.certificate_arn
}

# Returns the name of the ECR registry, this will be used later in various scripts
output "docker_registry" {
  value = module.env.docker_registry
}

