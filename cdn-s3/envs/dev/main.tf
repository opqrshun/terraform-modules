
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
  tags = var.tags
  zone = var.zone
  domain = var.domain
  
}



