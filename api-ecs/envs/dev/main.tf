
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}


provider "aws" {
  region  = var.region
  profile = var.aws_profile
}


module "dev" {
  source = "../../"

  region = var.region
  app = var.app
  environment = var.environment
  zone = var.zone
  domain = var.domain
  container_image = var.container_image
  container_port = var.container_port
  replicas = var.replicas
  ecs_autoscale_min_instances = var.ecs_autoscale_min_instances
  ecs_autoscale_max_instances = var.ecs_autoscale_max_instances
  lb_port = var.lb_port

  keybase_user = var.keybase_user
  api_audience = var.api_audience
  api_issuer = var.api_issuer

  tags = var.tags
  
}



