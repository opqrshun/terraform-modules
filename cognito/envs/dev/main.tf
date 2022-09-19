
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = var.aws_profile
}


module "cognito" {
  source = "../../"

  app         = var.app
  environment = var.environment
  zone        = var.zone
  domain      = var.domain

  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  tags                 = var.tags
}



