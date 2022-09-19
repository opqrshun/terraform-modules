
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

  aws_profile = var.aws_profile
  region      = var.region
  app         = var.app
  environment = var.environment
  tags        = var.tags
  zone        = var.zone
  domain      = var.domain
  cert_arn    = local.cert_arn

}


data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../../../base/envs/${var.environment}/terraform.tfstate"
  }
}

locals {
  cert_arn = data.terraform_remote_state.base.outputs.certificate_arn
}
