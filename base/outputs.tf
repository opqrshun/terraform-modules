output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "igw_id" {
  value = module.vpc.igw_id
}

# ACM
output "certificate_arn" {
  value = aws_acm_certificate.main.arn
}

# Returns the name of the ECR registry, this will be used later in various scripts
output "docker_registry" {
  value = aws_ecr_repository.app.repository_url
}

#
output "zone_id" {
  value = aws_route53_zone.main.zone_id
}

