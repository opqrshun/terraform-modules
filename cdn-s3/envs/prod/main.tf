
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}


provider "aws" {
  region  = var.region
  profile = var.aws_profile
}


module "cdn" {
  source = "../../"

  aws_profile = var.aws_profile
  region      = var.region
  app         = var.app
  environment = var.environment
  tags        = var.tags
  zone        = var.zone
  domain      = var.domain

  # us-ease-1 cert for cdn
  cert_arn = aws_acm_certificate.virginia_certificate.arn
}


