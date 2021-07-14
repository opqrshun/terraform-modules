
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}


module "ec2" {
  source = "../../"

  region = var.region
  app = var.app
  environment = var.environment
  domain = var.domain
  zone = var.zone
  tags = var.tags

  public_key = var.ec2_public_key
  
}



