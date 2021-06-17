
# Command to view the status of the Fargate service
output "vpc_id" {
  value = module.base.vpc_id
}

output "private_subnets" {
  value = module.base.private_subnets
}

output "public_subnets" {
  value = module.base.public_subnets
}

output "vpc_cidr_block" {
  value = module.base.vpc_cidr_block
}

output "igw_id" {
  value = module.base.igw_id
}

# ACM
output "certificate_arn" {
  value = module.base.certificate_arn
}

# Returns the name of the ECR registry, this will be used later in various scripts
output "docker_registry" {
  value = module.base.docker_registry
}

output "zone_id" {
  value = module.base.zone_id
}

